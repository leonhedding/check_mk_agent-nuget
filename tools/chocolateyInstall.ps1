$packageName = 'check_mk_agent'
$installerType = 'EXE'
$url = 'URL_HERE'
$silentArgs = '/S'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url"