$packageName = 'check_mk_agent'
$installerType = 'EXE'
$url = 'https://github.com/leonhedding/check_mk_agent-nuget/raw/master/nsis/check-mk-agent-1.2.4p5.exe'
$silentArgs = '/S'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url"