const {test} = require('node:test'), assert = require('node:assert/strict');
const fs = require('node:fs/promises'), path = require('node:path'), os = require('node:os');
const {spawnSync} = require('node:child_process'), {createHash} = require('node:crypto');
const root = path.resolve(__dirname, '..');
const quote = value => "'" + value.replaceAll("'", "'\\''") + "'";
async function fixture(t, systemNode = false) {
  const temporary = await fs.mkdtemp(path.join(os.tmpdir(), 'sfb-setup-'));
  t.after(() => fs.rm(temporary, {recursive:true, force:true}));
  const app = path.join(temporary, "Files & Games ' 100% $test"), tools = path.join(app,'tools/fs-rpc-browser'), bin = path.join(temporary,'bin');
  await fs.mkdir(tools,{recursive:true}); await fs.mkdir(bin);
  for (const name of ['bootstrap.sh','console.sh','requirements.cjs']) await fs.copyFile(path.join(root,'tools/fs-rpc-browser',name),path.join(tools,name));
  await fs.copyFile(path.join(root,'tools/fs-rpc-browser/launchers/start.sh'),path.join(app,'start.sh'));
  await fs.writeFile(path.join(app,'start.cjs'), "console.log('APP '+JSON.stringify(process.argv.slice(2))); process.exitCode=Number(process.env.SFB_APP_EXIT||0);\n");
  async function script(name,text) {await fs.writeFile(path.join(bin,name),'#!/bin/sh\n'+text+'\n',{mode:0o755});}
  await script('node',systemNode ? 'exec '+quote(process.execPath)+' "$@"' : 'exit 1');
  await script('uname','case "$1" in -s) echo Linux ;; -m) echo x86_64 ;; esac');
  await script('ldd','echo GLIBC');
  await script('curl','while [ "$#" -gt 0 ]; do case "$1" in --output) output=$2; shift ;; esac; shift; done\nprintf "download\\n" >> "$SFB_DOWNLOADS"\ncp "$SFB_FIXTURE_TAR" "$output"');
  const archiveRoot = path.join(temporary,'node-v22.23.4-linux-x64');
  await fs.mkdir(path.join(archiveRoot,'bin'),{recursive:true});
  await fs.writeFile(path.join(archiveRoot,'bin/node'),'#!/bin/sh\nexec '+quote(process.execPath)+' "$@"\n',{mode:0o755});
  await fs.writeFile(path.join(archiveRoot,'LICENSE'),'Fixture license\n');
  const archive = path.join(temporary,'fixture.tar.gz');
  const tar = spawnSync('tar',['-czf',archive,'-C',temporary,path.basename(archiveRoot)],{encoding:'utf8'});
  assert.equal(tar.status,0,tar.stderr);
  const hash = createHash('sha256').update(await fs.readFile(archive)).digest('hex');
  const metadata = path.join(tools,'node-runtimes.tsv');
  await fs.writeFile(metadata,'version\ttarget\tsha256\n22.23.4\tlinux-x64\t'+hash+'\n');
  const downloads = path.join(temporary,'downloads');
  const env = {...process.env, PATH:bin+path.delimiter+process.env.PATH, DISPLAY:'', WAYLAND_DISPLAY:'', SFB_TERMINAL:'', SFB_FIXTURE_TAR:archive, SFB_DOWNLOADS:downloads};
  const run = (args=[],extra={}) => spawnSync('sh',[path.join(app,'start.sh'),...args],{cwd:temporary,env:{...env,...extra},encoding:'utf8',timeout:15000});
  return {app,tools,bin,env,run,metadata,hash,downloads,script};
}
test('first-run Unix setup installs a verified runtime, preserves arguments and reuses it offline', {skip:process.platform==='win32'}, async t => {
  const f = await fixture(t), args = ['--help', 'spaces & $dollars', "it's 100%"];
  const first = f.run(args);
  assert.equal(first.status,0,first.stderr); assert.ok(first.stdout.includes('APP '+JSON.stringify(args)));
  assert.ok((await fs.stat(path.join(f.app,'data/runtime/node/bin/node'))).mode & 0o111);
  assert.equal(await fs.readFile(path.join(f.app,'data/runtime/node/LICENSE'),'utf8'),'Fixture license\n');
  await f.script('curl','echo Unexpected download >&2; exit 99');
  const second = f.run(args,{SFB_APP_EXIT:'7'});
  assert.equal(second.status,7,second.stderr); assert.ok(second.stdout.includes('APP '+JSON.stringify(args)));
  assert.equal(await fs.readFile(f.downloads,'utf8'),'download\n');
  assert.deepEqual((await fs.readdir(path.join(f.app,'data/runtime'))).sort(),['node']);
});
test('Unix setup discards a checksum failure, cleans its lock and allows a retry', {skip:process.platform==='win32'}, async t => {
  const f = await fixture(t);
  await fs.writeFile(f.metadata,'version\ttarget\tsha256\n22.23.4\tlinux-x64\t'+'0'.repeat(64)+'\n');
  const failed = f.run();
  assert.equal(failed.status,1); assert.match(failed.stderr,/checksum mismatch/); assert.ok(!failed.stdout.includes('APP '));
  assert.deepEqual(await fs.readdir(path.join(f.app,'data/runtime')),[]);
  await fs.writeFile(f.metadata,'version\ttarget\tsha256\n22.23.4\tlinux-x64\t'+f.hash+'\n');
  const retried = f.run(); assert.equal(retried.status,0,retried.stderr); assert.match(retried.stdout,/APP /);
});
test('an existing compatible Node.js runs without any dependency installation', {skip:process.platform==='win32'}, async t => {
  const f = await fixture(t,true), result = f.run(['--help']);
  assert.equal(result.status,0,result.stderr); assert.match(result.stdout,/APP /);
  await assert.rejects(fs.stat(path.join(f.app,'data')),{code:'ENOENT'});
  await assert.rejects(fs.stat(f.downloads),{code:'ENOENT'});
});
test('graphical Unix launch opens a console once and preserves paths and arguments', {skip:process.platform==='win32'}, async t => {
  const f = await fixture(t,true);
  await f.script('x-terminal-emulator','printf "terminal\\n" >> "$SFB_DOWNLOADS"\n[ "$1" = -e ] || exit 98\nshift\nexec "$@"');
  const result = f.run(['literal $arg & 100%'],{DISPLAY:':fixture'});
  assert.equal(result.status,0,result.stderr); assert.ok(result.stdout.includes('APP ["literal $arg & 100%"]'));
  assert.equal(await fs.readFile(f.downloads,'utf8'),'terminal\n');
});
test('Windows bootstrap installs a verified runtime, reuses it offline and rejects damaged downloads', {skip:process.platform!=='win32'}, async t => {
  const temporary = await fs.mkdtemp(path.join(os.tmpdir(),'sfb-windows-setup-'));
  t.after(() => fs.rm(temporary,{recursive:true,force:true}));
  const app = path.join(temporary,"Files & Games ' 100%"), tools = path.join(app,'tools/fs-rpc-browser');
  await fs.mkdir(tools,{recursive:true});
  await fs.copyFile(path.join(root,'tools/fs-rpc-browser/bootstrap.ps1'),path.join(tools,'bootstrap.ps1'));
  await fs.writeFile(path.join(app,'start.cjs'),"console.log('APP '+JSON.stringify(process.argv.slice(2)));\n");
  const harness = path.join(temporary,'harness.ps1');
  await fs.writeFile(harness, `
$ErrorActionPreference = 'Stop'
$app = $env:SFB_FIXTURE_APP
$tools = Join-Path $app 'tools/fs-rpc-browser'
$archive = Join-Path $env:SFB_FIXTURE_TEMP 'node.zip'
$target = if (($env:PROCESSOR_ARCHITEW6432 + $env:PROCESSOR_ARCHITECTURE) -match 'ARM64') { 'win-arm64' } elseif ([Environment]::Is64BitOperatingSystem) { 'win-x64' } else { 'win-x86' }
if (!(Test-Path -LiteralPath $archive)) {
  $directory = Join-Path $env:SFB_FIXTURE_TEMP ("node-v22.23.4-" + $target)
  New-Item -ItemType Directory -Path $directory | Out-Null
  Copy-Item -LiteralPath $env:SFB_FIXTURE_NODE -Destination (Join-Path $directory 'node.exe')
  Set-Content -LiteralPath (Join-Path $directory 'LICENSE') -Value 'Fixture license'
  Compress-Archive -LiteralPath $directory -DestinationPath $archive
}
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($env:SFB_BAD_CHECKSUM -eq '1') { $hash = '0' * 64 }
Set-Content -LiteralPath (Join-Path $tools 'node-runtimes.tsv') -Value ("version\ttarget\tsha256\n22.23.4\t" + $target + "\t" + $hash)
function Get-Command { param($Name, $CommandType, $ErrorAction) if ($Name -ne 'node.exe') { Microsoft.PowerShell.Core\\Get-Command @PSBoundParameters } }
function Invoke-WebRequest { param([switch]$UseBasicParsing, $Uri, $OutFile) if ($env:SFB_OFFLINE -eq '1') { throw 'Unexpected download' }; Add-Content -LiteralPath (Join-Path $env:SFB_FIXTURE_TEMP 'downloads') -Value 'download'; Copy-Item -LiteralPath $archive -Destination $OutFile }
& (Join-Path $tools 'bootstrap.ps1') start --help 'spaces & 100%'
`);
  const env = {...process.env,SFB_FIXTURE_APP:app,SFB_FIXTURE_TEMP:temporary,SFB_FIXTURE_NODE:process.execPath};
  const run = extra => spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',harness],{env:{...env,...extra},encoding:'utf8',timeout:120000});
  let result = run({SFB_BAD_CHECKSUM:'1'});
  assert.equal(result.status,1,result.stdout+result.stderr); assert.match(result.stdout,/checksum mismatch/);
  assert.deepEqual(await fs.readdir(path.join(app,'data/runtime')),[]);
  result = run({SFB_BAD_CHECKSUM:'0'});
  assert.equal(result.status,0,result.stdout+result.stderr); assert.ok(result.stdout.includes('APP ["--help","spaces & 100%"]'));
  result = run({SFB_OFFLINE:'1'});
  assert.equal(result.status,0,result.stdout+result.stderr); assert.match(result.stdout,/APP /);
  assert.deepEqual((await fs.readdir(path.join(app,'data/runtime'))).sort(),['node']);
});
