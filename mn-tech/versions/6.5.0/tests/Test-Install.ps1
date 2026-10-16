[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$TestRoot, [switch]$Apply)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$bundle = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ($TestRoot -notmatch '^[A-Za-z]:[\\/]') { throw 'Use an absolute local test path.' }
$testDirectory = [IO.Path]::GetFullPath($TestRoot).TrimEnd('\', '/')
if ($testDirectory.StartsWith($bundle, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'TestRoot must be outside the published bundle.'
}
if (Test-Path -LiteralPath $testDirectory) { throw 'TestRoot must be a new directory.' }
$cursor = $testDirectory
while ($cursor) {
    if (Test-Path -LiteralPath $cursor) {
        if (((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'TestRoot must not pass through links.'
        }
    }
    $cursor = [IO.Path]::GetDirectoryName($cursor)
}
if (-not $Apply) { 'Preview only: synthetic files would be created under ' + $testDirectory; return }
[void][IO.Directory]::CreateDirectory($testDirectory)
$installer = Join-Path $bundle 'scripts\Install-MnTechRea.ps1'
$results = New-Object 'System.Collections.Generic.List[string]'
function Check([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FAIL: $Name" }
    $results.Add($Name)
}
function Expect-Failure([scriptblock]$Action, [string]$Pattern) {
    try { & $Action | Out-Null } catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        return
    }
    throw "Expected failure matching: $Pattern"
}
function Hash-Tree([string]$Path) {
    $entries = @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force | Sort-Object FullName | ForEach-Object {
        $_.FullName.Substring($Path.Length) + ':' + (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    })
    return ($entries -join "`n")
}
function Copy-TestBundle([string]$Name) {
    $copy = Join-Path $testDirectory $Name
    [void][IO.Directory]::CreateDirectory($copy)
    foreach ($item in @('skill', 'scripts', 'manifest.json')) {
        Copy-Item -LiteralPath (Join-Path $bundle $item) -Destination $copy -Recurse
    }
    return $copy
}
function Assert-InTestRoot([string]$Path) {
    $resolved = [IO.Path]::GetFullPath($Path)
    if (-not $resolved.StartsWith($testDirectory + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Move escaped synthetic test root.'
    }
}

$skills = Join-Path $testDirectory ('skills with space ' + [char]0x6D4B)
$preview = & $installer -SkillsDirectory $skills | ConvertFrom-Json
Check ($preview.mode -eq 'preview' -and -not (Test-Path -LiteralPath $skills)) 'preview creates no destination'
[void][IO.Directory]::CreateDirectory($skills)
$sentinel = Join-Path $skills 'other-skill.txt'
[IO.File]::WriteAllText($sentinel, 'synthetic unrelated skill')
$installed = & $installer -SkillsDirectory $skills -Apply | ConvertFrom-Json
$active = Join-Path $skills 'reverse-engineer-anything'
$manifest = Get-Content -LiteralPath (Join-Path $bundle 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$matches = $true
foreach ($entry in $manifest.files) {
    if ((Get-FileHash -LiteralPath (Join-Path $active $entry.path)).Hash.ToLowerInvariant() -ne $entry.sha256) { $matches = $false }
}
Check ($installed.mode -eq 'installed' -and $matches) 'install in spaced Unicode path matches every payload hash'
Check ([IO.File]::ReadAllText($sentinel) -eq 'synthetic unrelated skill') 'unrelated sibling preserved'
$before = Hash-Tree $active
Expect-Failure { & $installer -SkillsDirectory $skills -Apply } 'Destination already exists'
Check ((Hash-Tree $active) -eq $before) 'repeat installation refuses overwrite'
Expect-Failure { & $installer -SkillsDirectory 'relative-skills' -Apply } 'absolute'
Expect-Failure { & $installer -SkillsDirectory 'C:drive-relative' -Apply } 'absolute'
Check $true 'relative and drive-relative destinations rejected'

$corrupt = Copy-TestBundle 'corrupt'
[IO.File]::AppendAllText((Join-Path $corrupt 'skill\reverse-engineer-anything\SKILL.md'), 'synthetic tamper')
$corruptOut = Join-Path $testDirectory 'corrupt-output'
Expect-Failure { & (Join-Path $corrupt 'scripts\Install-MnTechRea.ps1') -SkillsDirectory $corruptOut -Apply } 'integrity mismatch'
Check (-not (Test-Path -LiteralPath $corruptOut)) 'corrupt source rejected before writes'
$extra = Copy-TestBundle 'extra'
[IO.File]::WriteAllText((Join-Path $extra 'skill\reverse-engineer-anything\extra.md'), 'synthetic extra')
$extraOut = Join-Path $testDirectory 'extra-output'
Expect-Failure { & (Join-Path $extra 'scripts\Install-MnTechRea.ps1') -SkillsDirectory $extraOut -Apply } 'Unlisted payload'
Check (-not (Test-Path -LiteralPath $extraOut)) 'unlisted source rejected before writes'
$traversal = Copy-TestBundle 'traversal'
$badManifest = Get-Content -LiteralPath (Join-Path $traversal 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$badManifest.files[0].path = '../outside.md'
$badManifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $traversal 'manifest.json') -Encoding UTF8
$traversalOut = Join-Path $testDirectory 'traversal-output'
Expect-Failure { & (Join-Path $traversal 'scripts\Install-MnTechRea.ps1') -SkillsDirectory $traversalOut -Apply } 'Invalid or duplicate'
Check (-not (Test-Path -LiteralPath $traversalOut)) 'manifest traversal rejected before writes'

$linkTarget = Join-Path $testDirectory 'link-target'
$link = Join-Path $testDirectory 'linked-skills'
[void][IO.Directory]::CreateDirectory($linkTarget)
New-Item -ItemType Junction -Path $link -Target $linkTarget | Out-Null
Expect-Failure { & $installer -SkillsDirectory $link -Apply } 'symbolic link or junction'
Check (@(Get-ChildItem -LiteralPath $linkTarget -Force).Count -eq 0) 'junction destination rejected without touching target'

# Exercise the documented archive/restore sequence entirely inside this test root.
$rollbackSkills = Join-Path $testDirectory 'rollback-skills'
$rollbackActive = Join-Path $rollbackSkills 'reverse-engineer-anything'
$archive = Join-Path $testDirectory 'original-archive'
$retired = Join-Path $testDirectory 'retired-adaptation'
[void][IO.Directory]::CreateDirectory($rollbackActive)
[IO.File]::WriteAllText((Join-Path $rollbackActive 'original.md'), 'synthetic original bytes')
$originalHash = Hash-Tree $rollbackActive
foreach ($path in @($rollbackActive, $archive, $retired)) { Assert-InTestRoot $path }
Move-Item -LiteralPath $rollbackActive -Destination $archive -ErrorAction Stop
& $installer -SkillsDirectory $rollbackSkills -Apply | Out-Null
Move-Item -LiteralPath $rollbackActive -Destination $retired -ErrorAction Stop
Move-Item -LiteralPath $archive -Destination $rollbackActive -ErrorAction Stop
Check ((Hash-Tree $rollbackActive) -eq $originalHash -and (Test-Path -LiteralPath $retired)) 'manual backup and rollback restore original bytes and retain adaptation'

$report = [ordered]@{ result = 'PASS'; powershell = $PSVersionTable.PSVersion.ToString(); checks = @($results.ToArray()); count = $results.Count }
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $testDirectory 'result.json') -Encoding UTF8
$report | ConvertTo-Json -Depth 5
