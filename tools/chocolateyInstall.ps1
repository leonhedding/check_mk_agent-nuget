$packageName = 'check_mk_agent'
$installerType = 'EXE'
$installerName = 'check-mk-agent-1.2.4p5.exe'
$silentArgs = '/S'

try {
    $toolsPath     = Split-Path $MyInvocation.MyCommand.Definition
    $nsisPath      = Join-Path (Split-Path $toolsPath) nsis
    $installerPath = Join-Path $nsisPath $installerName

    Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$installerPath"
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
