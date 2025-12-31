!include "MUI2.nsh"

Name "WallyHaze"
OutFile "WallyHaze-1.0.0-Setup.exe"
InstallDir "$PROGRAMFILES64\WallyHaze"
InstallDirRegKey HKCU "Software\WallyHaze" ""
RequestExecutionLevel admin

!define MUI_ABORTWARNING
!define MUI_ICON "/home/wixisse/code/WallyHaze-Windows-1.0.0\wallyhaze.ico"
!define MUI_UNICON "/home/wixisse/code/WallyHaze-Windows-1.0.0\wallyhaze.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "WallyHaze" SecMain
    SetOutPath "$INSTDIR"
    File /r "/home/wixisse/code/WallyHaze-Windows-1.0.0\*.*"

    WriteRegStr HKCU "Software\WallyHaze" "" $INSTDIR
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    CreateDirectory "$SMPROGRAMS\WallyHaze"
    CreateShortCut "$SMPROGRAMS\WallyHaze\WallyHaze.lnk" "$INSTDIR\WallyHaze.exe"
    CreateShortCut "$SMPROGRAMS\WallyHaze\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\WallyHaze.lnk" "$INSTDIR\WallyHaze.exe"
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\*.*"
    RMDir /r "$INSTDIR"
    Delete "$SMPROGRAMS\WallyHaze\*.*"
    RMDir "$SMPROGRAMS\WallyHaze"
    Delete "$DESKTOP\WallyHaze.lnk"
    DeleteRegKey HKCU "Software\WallyHaze"
SectionEnd
