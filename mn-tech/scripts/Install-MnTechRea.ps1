# Copies only the reviewed instruction bundle. No runtime or MCP setup is run.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SkillsDirectory,
    [switch]$Apply
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-NoReparsePoint([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Refusing a symbolic link or junction: $cursor"
            }
        }
        $parent = [IO.Path]::GetDirectoryName($cursor)
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}

if ($SkillsDirectory -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+(?:\\|$))') {
    throw 'SkillsDirectory must be an absolute directory path.'
}
$bundleRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$source = Join-Path $bundleRoot 'skill\reverse-engineer-anything'
$manifestPath = Join-Path $bundleRoot 'manifest.json'
Assert-NoReparsePoint $manifestPath
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifest.schema_version -ne 1 -or $manifest.skill_name -ne 'reverse-engineer-anything') {
    throw 'Unsupported bundle manifest.'
}
$destination = Join-Path ([IO.Path]::GetFullPath($SkillsDirectory)) $manifest.skill_name
Assert-NoReparsePoint $destination
if (Test-Path -LiteralPath $destination) {
    throw "Destination already exists; nothing was changed. Review and archive it outside the active skills directory first: $destination"
}
$expected = @{}
foreach ($entry in $manifest.files) {
    $relative = [string]$entry.path
    if ($relative -notmatch '^[a-zA-Z0-9_-]+(?:[./][a-zA-Z0-9_-]+)*$' -or
        $relative.Contains('..') -or $expected.ContainsKey($relative) -or
        $entry.sha256 -notmatch '^[0-9a-f]{64}$') {
        throw "Invalid or duplicate manifest entry: $relative"
    }
    $file = Join-Path $source ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    Assert-NoReparsePoint $file
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing payload: $relative" }
    if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) {
        throw "Payload integrity mismatch: $relative"
    }
    $expected[$relative] = $entry.sha256
}
if ($expected.Count -eq 0 -or -not $expected.ContainsKey('SKILL.md')) { throw 'Empty or incomplete payload.' }
Assert-NoReparsePoint $source
$pending = New-Object 'System.Collections.Generic.Queue[string]'
$pending.Enqueue($source)
$actual = New-Object 'System.Collections.Generic.List[object]'
while ($pending.Count -gt 0) {
    foreach ($item in @(Get-ChildItem -LiteralPath $pending.Dequeue() -Force)) {
        Assert-NoReparsePoint $item.FullName
        if ($item.PSIsContainer) { $pending.Enqueue($item.FullName) }
        else { $actual.Add($item) }
    }
}
$sourcePrefix = $source.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
foreach ($file in $actual) {
    $relative = $file.FullName.Substring($sourcePrefix.Length).Replace('\', '/')
    if (-not $expected.ContainsKey($relative)) { throw "Unlisted payload file: $relative" }
}
if ($actual.Count -ne $expected.Count) { throw 'Payload file count mismatch.' }
$result = [ordered]@{
    mode = 'preview'; adaptation = $manifest.adaptation; runtime_baseline = $manifest.runtime_baseline
    destination = $destination; file_count = $expected.Count
    runtime_changed = $false; mcp_configuration_changed = $false
    files = @($expected.Keys | Sort-Object)
}
if (-not $Apply) { $result | ConvertTo-Json -Depth 5; return }

# Every output file uses overwrite=false. A partial failure is retained for review.
# Do not run concurrent installations into the same destination.
try {
    Assert-NoReparsePoint $destination
    if (Test-Path -LiteralPath $destination) { throw 'Destination appeared during preflight.' }
    [void][IO.Directory]::CreateDirectory($destination)
    foreach ($relative in @($expected.Keys | Sort-Object)) {
        $from = Join-Path $source $relative
        $to = Join-Path $destination $relative
        Assert-NoReparsePoint $to
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to))
        [IO.File]::Copy($from, $to, $false)
        if ((Get-FileHash -LiteralPath $to -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected[$relative]) {
            throw "Copied file integrity mismatch: $relative"
        }
    }
    $result.mode = 'installed'
    $result | ConvertTo-Json -Depth 5
} catch {
    throw "Installation stopped: $($_.Exception.Message). Inspect any partial folder before retrying: $destination"
}
