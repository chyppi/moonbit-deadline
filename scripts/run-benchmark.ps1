[CmdletBinding()]
param(
  [int]$Iterations = 100,
  [string]$OutputPath = "docs/benchmarks/latest.md"
)

$ErrorActionPreference = "Stop"
if ($Iterations -lt 1) { throw "Iterations must be positive" }
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

$version = (moon version --all | Out-String).Trim()
$watch = [Diagnostics.Stopwatch]::StartNew()
$output = @(moon run bench/deadline_bench -- --iterations $Iterations)
$exitCode = $LASTEXITCODE
$watch.Stop()
if ($exitCode -ne 0) { throw "Benchmark command failed with exit code $exitCode" }
$elapsedText = $watch.Elapsed.TotalMilliseconds.ToString("0.00")

$resolvedOutput = Join-Path $root $OutputPath
$parent = Split-Path -Parent $resolvedOutput
if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
$benchmarkOutput = $output -join "`n"
$content = @"
# 本地 benchmark 结果

运行日期：$(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")

工具链：

~~~text
$version
~~~

命令：`moon run bench/deadline_bench -- --iterations $Iterations`

~~~text
$benchmarkOutput
~~~

外层命令耗时：$elapsedText ms

checksum 用于确认 workload 真实完成；耗时受机器、操作系统和工具链影响，不作为跨机器性能承诺。
"@
$content | Set-Content -LiteralPath $resolvedOutput -Encoding utf8
$content | Write-Output
