; This is the NSIS configuration file for the Check_MK windows agent. This is
; the spec file how to build the installer
;--------------------------------
; Useful sources:
; http://nsis.sourceforge.net/Reusable_installer_script
!include "FileFunc.nsh"

!define MAJOR_VERSION "1"
!define MINOR_VERSION "2.4p5"
!define CHECK_MK_VERSION "${MAJOR_VERSION}.${MINOR_VERSION}"
!define NAME "Check_MK Agent ${CHECK_MK_VERSION}"
!define VERSION "${CHECK_MK_VERSION}"
!define PRODUCT_VERSION "${CHECK_MK_VERSION}"
!define PRODUCT_PUBLISHER "Mathias Kettner GmbH"
!define PRODUCT_WEB_SITE "http://mathias-kettner.com/checkmk_monitoring_system.html"

XPStyle on
Icon "check_mk_agent.ico"

; The name of the installer
Name "${NAME}"

; The file to write
OutFile "check-mk-agent-${CHECK_MK_VERSION}.exe"

SetDateSave on
SetDatablockOptimize on
CRCCheck on
SilentInstall normal

; The default installation directory
InstallDir "$PROGRAMFILES\check_mk"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\check_mk_agent" "Install_Dir"

; Request application privileges for Windows >Vista
RequestExecutionLevel admin

ShowInstDetails show

;--------------------------------
; Pages

Page directory
Page components
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

Section "Check_MK_Agent"
    ; Can not be disabled
    SectionIn RO

    !include LogicLib.nsh
    ExpandEnvStrings $0 "%comspec%"
    nsExec::ExecToStack '"$0" /k "net start | FIND /C /I "check_mk_agent""'
    Pop $0
    Pop $1
    StrCpy $1 $1 1
    Var /GLOBAL stopped
    ${If} "$0$1" == "01"
        DetailPrint "Stop running check_mk_agent..."
        StrCpy $stopped "1"
        nsExec::Exec 'cmd /C "net stop check_mk_agent"'
    ${Else}
        StrCpy $stopped "0"
    ${EndIf}

    SetOutPath "$INSTDIR"
    File check_mk_agent.exe
    File check_mk_agent.ico
    ; not leaving in installer as this should be customised at each installation location
    ;File check_mk.ini 
    File check_mk.example.ini
    CreateDirectory "$INSTDIR\local"
    CreateDirectory "$INSTDIR\plugins"

    !define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\check_mk_agent"
    
    ; Write the installation path into the registry
    WriteRegStr HKLM SOFTWARE\check_mk_agent "Install_Dir" "$INSTDIR"
    
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
  
    ; Write the uninstall keys for Windows
    WriteRegStr HKLM ${ARP} "DisplayName" "${NAME}"
    WriteRegStr HKLM ${ARP} "Version" "${VERSION}"
    WriteRegStr HKLM ${ARP} "DisplayIcon" "$INSTDIR\check_mk_agent.ico"
    WriteRegStr HKLM ${ARP} "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM ${ARP} "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr HKLM ${ARP} "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegDWORD HKLM ${ARP} "EstimatedSize" "$0"
    WriteRegStr HKLM ${ARP} "VersionMajor"  "${MAJOR_VERSION}"
    WriteRegStr HKLM ${ARP} "VersionMinor" "${MINOR_VERSION}"
    WriteRegStr HKLM ${ARP} "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM ${ARP} "NoModify" 1
    WriteRegDWORD HKLM ${ARP} "NoRepair" 1
    WriteUninstaller "uninstall.exe"
SectionEnd

Section "Install & start service"
    DetailPrint "Installing and starting the check_mk_agent service..."
    nsExec::Exec 'cmd /C "$INSTDIR\check_mk_agent.exe" install'
    nsExec::Exec 'cmd /C "net start check_mk_agent"'
    nsExec::Exec 'cmd /C netsh advfirewall firewall delete rule name="check_mk_agent.exe" program="$INSTDIR\check_mk_agent.exe"'
    nsExec::Exec 'cmd /C netsh advfirewall firewall add rule name="check_mk_agent.exe" dir=in action=allow program="$INSTDIR\check_mk_agent.exe" enable=yes'
SectionEnd

Section "Uninstall"
    ; Remove the service
    DetailPrint "Stopping service..."
    nsExec::Exec 'cmd /C "net stop check_mk_agent"'
    DetailPrint "Removing service..."
    nsExec::Exec 'cmd /C "$INSTDIR\check_mk_agent.exe" remove'
    nsExec::Exec 'cmd /C netsh advfirewall firewall delete rule name="check_mk_agent.exe" program="$INSTDIR\check_mk_agent.exe"'
  
    ; Remove registry keys
    DeleteRegKey HKLM ${ARP}
    DeleteRegKey HKLM SOFTWARE\check_mk_agent
  
    ; Remove files and uninstaller
    Delete "$INSTDIR\check_mk_agent.exe"
    Delete "$INSTDIR\check_mk.ini"
    Delete "$INSTDIR\check_mk.example.ini"
    Delete "$INSTDIR\check_mk_agent.ico"
    Delete "$INSTDIR\logstate.txt"
    Delete "$INSTDIR\plugins\*.*"
    Delete "$INSTDIR\local\*.*"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR\local"
    RMDir "$INSTDIR\plugins"
  
    ; Remove directories used
    RMDir "$INSTDIR"
SectionEnd
