$packageName = 'check_mk_agent'
$installerType = 'EXE'
$silentArgs = '/S'

try {
    #Check for 64/32-bit OS
    if(Test-Path "c:\Program Files (x86)") {
        $checkMKInstallationPath = "c:\Program Files (x86)\check_mk"
    } else {
        $checkMKInstallationPath = "c:\Program Files\check_mk"
    }

    $uninstallerPath= Join-Path $checkMKINstallationPath "uninstall.exe"

    Uninstall-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$uninstallerPath"
    Write-ChocolateySuccess "$packageName"
} catch {
    Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
    throw
}
