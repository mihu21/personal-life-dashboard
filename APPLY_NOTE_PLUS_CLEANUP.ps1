$ErrorActionPreference = 'Stop'
$shoppingPath = Join-Path $PSScriptRoot 'lib\features\shopping'
if (Test-Path $shoppingPath) {
  Remove-Item $shoppingPath -Recurse -Force
  Write-Host 'Removed obsolete lib/features/shopping feature.'
} else {
  Write-Host 'lib/features/shopping is already removed.'
}
