[CmdletBinding()]
param(
  [switch]$RunChecks
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

Write-Output "== MoonBit toolchain =="
moon version --all

$sourceFiles = @(Get-ChildItem -Path $root -Recurse -File -Filter "*.mbt" |
  Where-Object {
    $_.FullName -notmatch "[\\/](_build|target|node_modules|\.moon)[\\/]" -and
    $_.Name -notmatch "^pkg\.generated\.mbti$"
  } | Sort-Object FullName)
$sourceLines = ($sourceFiles | ForEach-Object { (Get-Content -LiteralPath $_.FullName).Count } |
  Measure-Object -Sum).Sum
$testCount = ($sourceFiles | ForEach-Object {
  (Select-String -LiteralPath $_.FullName -Pattern '^\s*test\s+"' -AllMatches).Count
} | Measure-Object -Sum).Sum

Write-Output "== Effective MoonBit source =="
Write-Output ("files={0} lines={1} tests={2}" -f $sourceFiles.Count, $sourceLines, $testCount)
foreach ($file in $sourceFiles) {
  $relative = [IO.Path]::GetRelativePath($root, $file.FullName)
  $lines = (Get-Content -LiteralPath $file.FullName).Count
  Write-Output ("{0,6} {1}" -f $lines, $relative)
}

Write-Output "== Repository state =="
git status --short --branch
git remote show origin 2>$null | Select-String -Pattern "HEAD branch|Remote branch|tracked"

if (Test-Path "docs/moonbit-hackathon-application.md") {
  $proposal = Get-Item "docs/moonbit-hackathon-application.md"
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $proposal.FullName).Hash
  Write-Output ("proposal_sha256={0}" -f $hash)
}

if ($RunChecks) {
  Write-Output "== MoonBit checks =="
  moon check --target all --deny-warn
  moon test --target all --deny-warn
}
