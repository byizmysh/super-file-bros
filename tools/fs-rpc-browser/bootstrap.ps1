param(
    [Parameter(Position=0)][ValidateSet('start', 'install')][string]$Action = 'start',
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$LaunchArguments
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Join-Path $PSScriptRoot '../..')
function Test-Node([string]$Command) {
    try {
        $version = & $Command --version 2>$null
        if ($LASTEXITCODE -ne 0 -or $version -notmatch '^v(\d+)\.(\d+)\.') { return $false }
        return ([int]$Matches[1] -gt 20 -or ([int]$Matches[1] -eq 20 -and [int]$Matches[2] -ge 20))
    } catch { return $false }
}
try {
    Write-Host 'Super File Bros. - checking dependencies...'
    $node = $null
    $systemNode = Get-Command node.exe -CommandType Application -ErrorAction SilentlyContinue
    if ($systemNode -and (Test-Node $systemNode.Source)) { $node = $systemNode.Source }
    $runtime = Join-Path (Get-Location).Path 'data/runtime'
    $localNode = Join-Path $runtime 'node/node.exe'
    if (!$node -and (Test-Path -LiteralPath $localNode) -and (Test-Node $localNode)) { $node = $localNode }
    if (!$node) {
        $architecture = $env:PROCESSOR_ARCHITEW6432
        if (!$architecture) { $architecture = $env:PROCESSOR_ARCHITECTURE }
        $target = switch ($architecture) { 'AMD64' { 'win-x64' } 'ARM64' { 'win-arm64' } 'x86' { 'win-x86' } default { throw 'Unsupported CPU. Install Node.js 20.20+ manually.' } }
        $release = Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'node-runtimes.tsv') -Delimiter "`t" | Where-Object target -eq $target
        if (!$release) { throw "No automatic Node.js download for $target." }
        New-Item -ItemType Directory -Force -Path $runtime | Out-Null
        $lock = Join-Path $runtime '.install-lock'
        $locked = $false
        $work = $null
        try {
            for ($attempt = 0; !$locked; $attempt++) {
                try { New-Item -ItemType Directory -Path $lock -ErrorAction Stop | Out-Null; $locked = $true }
                catch {
                    if ($attempt -eq 0) { Write-Host 'Waiting for another first-run setup to finish...' }
                    if ($attempt -ge 300) { throw 'Setup is still locked. Close other launchers; if none are running, remove data/runtime/.install-lock and retry.' }
                    Start-Sleep -Seconds 1
                }
            }
            if (!(Test-Path -LiteralPath $localNode) -or !(Test-Node $localNode)) {
                $work = Join-Path $runtime ('.setup.' + [guid]::NewGuid().ToString('N'))
                New-Item -ItemType Directory -Path $work | Out-Null
                $name = "node-v$($release.version)-$target"
                Write-Host "Node.js is missing or too old. Downloading Node.js $($release.version) for $target from nodejs.org..."
                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
                $archive = Join-Path $work 'node.zip'
                Invoke-WebRequest -UseBasicParsing -Uri "https://nodejs.org/dist/v$($release.version)/$name.zip" -OutFile $archive
                if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $release.sha256) { throw 'Node.js checksum mismatch. The download was discarded. Retry or install Node.js from its official website.' }
                Expand-Archive -LiteralPath $archive -DestinationPath $work
                $ready = Join-Path $work 'ready'
                New-Item -ItemType Directory -Path $ready | Out-Null
                Copy-Item -LiteralPath (Join-Path $work "$name/node.exe"), (Join-Path $work "$name/LICENSE") -Destination $ready
                if (!(Test-Node (Join-Path $ready 'node.exe'))) { throw 'The downloaded Node.js cannot run on this OS. Install a compatible Node.js 20.20+ manually, then retry.' }
                if (Test-Path -LiteralPath (Join-Path $runtime 'node')) { Remove-Item -LiteralPath (Join-Path $runtime 'node') -Recurse -Force }
                Move-Item -LiteralPath $ready -Destination (Join-Path $runtime 'node')
                Write-Host "Node.js installed in $runtime\node. Future launches reuse it."
            }
            $node = $localNode
        } finally {
            if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force }
            if ($locked) { Remove-Item -LiteralPath $lock -Force }
        }
    }
    $entry = if ($Action -eq 'install') { 'tools/fs-rpc-browser/install.cjs' } else { 'start.cjs' }
    & $node $entry @LaunchArguments
    exit $LASTEXITCODE
} catch {
    Write-Host "Setup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Check your Internet connection and retry. You can also install Node.js 20.20+ from https://nodejs.org/.'
    exit 1
}
