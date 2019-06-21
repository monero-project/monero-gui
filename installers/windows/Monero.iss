; Monero Boron Butterfly GUI Wallet Installer for Windows
; Copyright (c) 2017-2019, The Monero Project
; See LICENSE

[Setup]
AppName=Monero GUI Wallet
; For InnoSetup this is the property that uniquely identifies the application as such
; Thus it's important to keep this stable over releases
; With a different "AppName" InnoSetup would treat a mere update as a completely new application and thus mess up

AppVersion=0.14.1.0
DefaultDirName={pf}\Monero GUI Wallet
DefaultGroupName=Monero GUI Wallet
UninstallDisplayIcon={app}\monero-wallet-gui.exe
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
WizardSmallImageFile=WizardSmallImage.bmp
WizardImageFile=WelcomeImage.bmp
DisableWelcomePage=no
LicenseFile=LICENSE
AppPublisher=The Monero Developer Community
AppPublisherURL=https://getmonero.org

UsedUserAreasWarning=no
; The above directive silences the following compiler warning:
;    Warning: The [Setup] section directive "PrivilegesRequired" is set to "admin" but per-user areas (HKCU,userdocs)
;    are used by the script. Regardless of the version of Windows, if the installation is administrative then you should
;    be careful about making any per-user area changes: such changes may not achieve what you are intending.
; Background info:
; This installer indeed asks for admin rights so the Monero files can be copied to a place where they have at least
; a minimum of protection against changes, e.g. by malware, plus it handles things for the currently logged-in user
; in the registry (GUI wallet per-user options) and for some of the icons. For reasons too complicated to fully explain
; here this does not work as intended if the installing user does not have admin rights and has to provide the password
; of a user that does for installing: The settings of the admin user instead of those of the installing user are changed.
; Short of ripping out that per-user functionality the issue has no suitable solution. Fortunately, this will probably
; play a role in only in few cases as the first standard user in a Windows installation does have admin rights.
; So, for the time being, this installer simply disregards this problem.


[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
; Without localized versions of special forms, messages etc. of the installer, and without translated ReadMe's
; it probably does not make much sense to offer other install-time languages beside English
; Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
; Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
; Name: "jp"; MessagesFile: "compiler:Languages\Japanese.isl"
; Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl"
; Name: "pt"; MessagesFile: "compiler:Languages\Portuguese.isl"


[Files]
; The use of the flag "ignoreversion" for the following entries leads to the following behaviour:
; When updating / upgrading an existing installation ALL existing files are replaced with the files in this
; installer, regardless of file dates, version info within the files, or type of file (textual file or
; .exe/.dll file possibly with version info).
;
; This is far more robust than relying on version info or on file dates (flag "comparetimestamp").
; As of version 0.14.1.0, the Monero .exe files do not carry version info anyway in their .exe headers.
; The only small drawback seems to be somewhat longer update times because each and every file is
; copied again, even if already present with correct file date and identical content.
;
; Note that it would be very dangerous to use "ignoreversion" on files that may be shared with other
; applications somehow. Luckily this is no issue here because ALL files are "private" to Monero.

Source: "ReadMe.htm"; DestDir: "{app}"; Flags: ignoreversion
Source: "FinishImage.bmp"; Flags: dontcopy

; Monero GUI wallet exe and guide
Source: "bin\monero-wallet-gui.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-GUI-guide.pdf"; DestDir: "{app}"; Flags: ignoreversion

; Monero CLI wallet
Source: "bin\monero-wallet-cli.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-gen-trusted-multisig.exe"; DestDir: "{app}"; Flags: ignoreversion

; Monero wallet RPC interface implementation
Source: "bin\monero-wallet-rpc.exe"; DestDir: "{app}"; Flags: ignoreversion

; Monero daemon
Source: "bin\monerod.exe"; DestDir: "{app}"; Flags: ignoreversion

; Monero daemon wrapped in a batch file that stops before the text window closes, to see any error messages
Source: "monero-daemon.bat"; DestDir: "{app}"; Flags: ignoreversion;

; Monero blockchain utilities
Source: "bin\monero-blockchain-export.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-import.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-mark-spent-outputs.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-usage.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-import.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-ancestry.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-depth.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-prune-known-spent-data.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-prune.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\monero-blockchain-stats.exe"; DestDir: "{app}"; Flags: ignoreversion

; Qt Quick 2D Renderer fallback for systems / environments with "low-level graphics" i.e. without 3D support
Source: "bin\start-low-graphics-mode.bat"; DestDir: "{app}"; Flags: ignoreversion

; Mesa, open-source OpenGL implementation; part of "low-level graphics" support
Source: "bin\opengl32sw.dll"; DestDir: "{app}"; Flags: ignoreversion


; Delete any files and directories that were installed by previous installer versions but are not
; needed anymore, thanks to the static linking of the GUI wallet exe - all those things are now
; neatly contained in that single exe file;
; InnoSetup does NOT automatically delete objects not present anymore in a new version.
; Deleting them is simpler and faster than forcing a full re-install.
[InstallDelete]
Type: filesandordirs; Name: "{app}\translations"
Type: files; Name: "{app}\Qt5*.dll"
Type: filesandordirs; Name: "{app}\Qt"
Type: filesandordirs; Name: "{app}\audio"
Type: filesandordirs; Name: "{app}\bearer"
Type: filesandordirs; Name: "{app}\platforms"
Type: filesandordirs; Name: "{app}\platforminputcontexts"
Type: filesandordirs; Name: "{app}\iconengines"
Type: filesandordirs; Name: "{app}\imageformats"
Type: filesandordirs; Name: "{app}\QtMultimedia"
Type: filesandordirs; Name: "{app}\mediaservice"
Type: filesandordirs; Name: "{app}\playlistformats"
Type: filesandordirs; Name: "{app}\QtGraphicalEffects"
Type: filesandordirs; Name: "{app}\private"
Type: filesandordirs; Name: "{app}\QtQml"
Type: filesandordirs; Name: "{app}\QtQuick"
Type: filesandordirs; Name: "{app}\QtQuick.2"
Type: filesandordirs; Name: "{app}\Material"
Type: filesandordirs; Name: "{app}\Universal"
Type: filesandordirs; Name: "{app}\scenegraph"
Type: files; Name: "{app}\D3Dcompiler_47.dll"
Type: files; Name: "{app}\libbz2-1.dll"
Type: files; Name: "{app}\libEGL.dll"
Type: files; Name: "{app}\libGLESV2.dll"
Type: files; Name: "{app}\libfreetype-6.dll"
Type: files; Name: "{app}\libgcc_s_seh-1.dll"
Type: files; Name: "{app}\libglib-2.0-0.dll"
Type: files; Name: "{app}\libgraphite2.dll"
Type: files; Name: "{app}\libharfbuzz-0.dll"
Type: files; Name: "{app}\libiconv-2.dll"
Type: files; Name: "{app}\libicudt??.dll"
Type: files; Name: "{app}\libicuin??.dll"
Type: files; Name: "{app}\libicuio??.dll"
Type: files; Name: "{app}\libicutu??.dll"
Type: files; Name: "{app}\libicuuc??.dll"
Type: files; Name: "{app}\libintl-8.dll"
Type: files; Name: "{app}\libjpeg-8.dll"
Type: files; Name: "{app}\liblcms2-2.dll"
Type: files; Name: "{app}\liblzma-5.dll"
Type: files; Name: "{app}\libmng-2.dll"
Type: files; Name: "{app}\libpcre-1.dll"
Type: files; Name: "{app}\libpcre16-0.dll"
Type: files; Name: "{app}\libpcre2-16-0.dll"
Type: files; Name: "{app}\libpng16-16.dll"
Type: files; Name: "{app}\libstdc++-6.dll"
Type: files; Name: "{app}\libtiff-5.dll"
Type: files; Name: "{app}\libwinpthread-1.dll"
Type: files; Name: "{app}\zlib1.dll"
Type: files; Name: "{app}\libssp-0.dll"
Type: files; Name: "{app}\libhidapi-0.dll"
Type: files; Name: "{app}\libeay32.dll"
Type: files; Name: "{app}\ssleay32.dll"


[Tasks]
Name: desktopicon; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:";


[Run]
Filename: "{app}\ReadMe.htm"; Description: "Show ReadMe"; Flags: postinstall shellexec skipifsilent

; DON'T offer to run the wallet right away, let the people read about initial blockchain download first in the ReadMe
; Filename: "{app}\monero-wallet-gui.exe"; Description: "Run GUI Wallet now"; Flags: postinstall nowait skipifsilent


[Code]
var
  BlockChainDirPage: TInputDirWizardPage;
  blockChainDefaultDir: String;

procedure InitializeWizard;
var s: String;
    blockChainDir: String;
begin
  // Large image for the "Welcome" page, with page reconfigured
  WizardForm.WelcomeLabel1.Visible := false;
  WizardForm.WelcomeLabel2.Visible := false;
  WizardForm.WizardBitmapImage.Height := 300;
  WizardForm.WizardBitmapImage.Width := 500;

  // Image for the "Finnish" screen, in standard WizardBitmapImage size of 164 x 314
  ExtractTemporaryFile('FinishImage.bmp');
  WizardForm.WizardBitmapImage2.Bitmap.LoadFromFile(ExpandConstant('{tmp}\FinishImage.bmp'));

  // Additional wizard page for entering a special blockchain location
  blockChainDefaultDir := ExpandConstant('{commonappdata}\bitmonero');
  s := 'The default folder to store the Monero blockchain is ' + blockChainDefaultDir;
  s := s + '. As this will need more than 70 GB of free space, you may want to use a folder on a different drive.';
  s := s + ' If yes, specify that folder here.';

  BlockChainDirPage := CreateInputDirPage(wpSelectDir,
    'Select Blockchain Directory', 'Where should the blockchain be installed?',
    s,
    False, '');
  BlockChainDirPage.Add('');

  // Evaluate proposal for the blockchain location
  // In case of an update take the blockchain location from the actual setting in the registry
  RegQueryStringValue(HKEY_CURRENT_USER, 'Software\monero-project\monero-core', 'blockchainDataDir', blockChainDir);
  if blockChainDir = '' then begin
    blockChainDir := GetPreviousData('BlockChainDir', '');
  end;
  if blockChainDir = '' then begin
    // Unfortunately 'TInputDirWizardDirPage' does not allow empty field, so "propose" Monero default location
    blockChainDir := blockChainDefaultDir;
  end;
  BlockChainDirPage.Values[0] := blockChainDir;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  // Store the selected folder for further reinstall/upgrade
  SetPreviousData(PreviousDataKey, 'BlockChainDir', BlockChainDirPage.Values[0]);
end;

function BlockChainDir(Param: String) : String;
// Directory of the blockchain
var s: String;
begin
  s := BlockChainDirPage.Values[0];
  Result := s;
  // No quotes for folder name with blanks as this is never used as part of a command line
end;

function BlockChainDirOrEmpty(Param: String) : String;
VAR s: String;
begin
  s := BlockChainDir('');
  if s = blockChainDefaultDir then begin
    // No need to add the default dir as setting
    s := '';
  end;
  Result := s;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var s: String;
begin
  // Fill the 'Ready Memo' with the normal settings and the custom settings
  s := '';
  s := s + MemoDirInfo + NewLine + NewLine;

  s := s + 'Blockchain folder' + NewLine;
  s := s + Space + BlockChainDir('') + NewLine;

  Result := s;
end;

function DaemonLog(Param: String) : String;
// Full filename of the log of the daemon
begin
  Result := BlockChainDir('') + '\bitmonero.log';
  // No quotes for filename with blanks as this is never used as part of a command line
end;

function DaemonFlags(Param: String): String;
// Flags to add to the shortcut to the daemon
var s: String;
begin
  s := BlockChainDir('');
  if s = blockChainDefaultDir then begin
    // No need to add the default dir as flags for the daemon
    s := '';
  end;
  if Pos(' ', s) > 0 then begin
    // Quotes needed for filename with blanks
    s := '"' + s + '"';
  end;
  if s <> '' then begin
    s := '--data-dir ' + s;
  end;
  Result := s;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var s: TArrayOfString;
begin
  if CurStep = ssPostInstall then begin
    // Re-build "monero-daemon.bat" according to actual install and blockchain directory used
    SetArrayLength(s, 3);
    s[0] := 'REM Execute the Monero daemon and then stay with window open after it exits';
    s[1] := '"' + ExpandConstant('{app}\monerod.exe') + '" ' + DaemonFlags('');
    s[2] := 'PAUSE';
    SaveStringsToFile(ExpandConstant('{app}\monero-daemon.bat'), s, false); 
  end;
end;

function InitializeUninstall(): Boolean;
var s: String;
begin
  s := 'Please note: Uninstall will not delete any downloaded blockchain. ';
  s := s + 'If you do not need it anymore you have to delete it manually.';
  s := s + #13#10#13#10 + 'Uninstall will not delete any wallets that you created either.';
  MsgBox(s, mbInformation, MB_OK);
  Result := true;
end;


[Icons]
; Icons in the "Monero GUI Wallet" program group
; Windows will almost always display icons in alphabetical order, per level, so specify the text accordingly
Name: "{group}\GUI Wallet"; Filename: "{app}\monero-wallet-gui.exe";
Name: "{group}\GUI Wallet Guide"; Filename: "{app}\monero-GUI-guide.pdf"; IconFilename: "{app}\monero-wallet-gui.exe"
Name: "{group}\Uninstall GUI Wallet"; Filename: "{uninstallexe}"

; Sub-folder "Utilities";
; Note that Windows 10, unlike Windows 7, ignores such sub-folders completely
; and insists on displaying ALL icons on one single level
Name: "{group}\Utilities\Monero Daemon"; Filename: "{app}\monerod.exe"; Parameters: {code:DaemonFlags}
Name: "{group}\Utilities\Read Me"; Filename: "{app}\ReadMe.htm"

; CLI wallet: Needs a working directory ("Start in:") set in the icon, because with no such directory set
; it tries to create new wallets without a path given in the probably non-writable program folder and will abort with an error
Name: "{group}\Utilities\Textual (CLI) Wallet"; Filename: "{app}\monero-wallet-cli.exe"; WorkingDir: "{userdocs}\Monero\wallets"

; Icons for troubleshooting problems / testing / debugging
; To show that they are in some way different (not for everyday use), make them visually different
; from the others by text, and make them sort at the end by the help of "x" in front 
Name: "{group}\Utilities\x (Check Blockchain Folder)"; Filename: "{win}\Explorer.exe"; Parameters: {code:BlockChainDir}
Name: "{group}\Utilities\x (Check Daemon Log)"; Filename: "Notepad"; Parameters: {code:DaemonLog}
Name: "{group}\Utilities\x (Check Default Wallet Folder)"; Filename: "{win}\Explorer.exe"; Parameters: """{userdocs}\Monero\wallets"""
Name: "{group}\Utilities\x (Check GUI Wallet Log)"; Filename: "Notepad"; Parameters: """{userappdata}\monero-wallet-gui\monero-wallet-gui.log"""
Name: "{group}\Utilities\x (Try Daemon, Exit Confirm)"; Filename: "{app}\monero-daemon.bat"
Name: "{group}\Utilities\x (Try GUI Wallet Low Graphics Mode)"; Filename: "{app}\start-low-graphics-mode.bat"
Name: "{group}\Utilities\x (Try Kill Daemon)"; Filename: "Taskkill.exe"; Parameters: "/IM monerod.exe /T /F"

; Desktop icons, optional with the help of the "Task" section
Name: "{commondesktop}\GUI Wallet"; Filename: "{app}\monero-wallet-gui.exe"; Tasks: desktopicon


[Registry]
; Store any special flags for the daemon in the registry location where the GUI wallet will take it from
; So if the wallet is used to start the daemon instead of the separate icon the wallet will pass the correct flags
; Side effect, mostly positive: The uninstaller will clean the registry
Root: HKCU; Subkey: "Software\monero-project"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\monero-project\monero-core"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\monero-project\monero-core"; ValueType: string; ValueName: "blockchainDataDir"; ValueData: {code:BlockChainDirOrEmpty};

; Configure a custom URI scheme: Links starting with "monero:" will start the GUI wallet exe with the URI as command-line parameter
; Used to easily start payments; example URI: "monero://<address>?tx_amount=5.0"
Root: HKCR; Subkey: "monero"; ValueType: "string"; ValueData: "URL:Monero Payment Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "monero"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "monero\DefaultIcon"; ValueType: "string"; ValueData: "{app}\monero-wallet-gui.exe,0"
Root: HKCR; Subkey: "monero\shell\open\command"; ValueType: "string"; ValueData: """{app}\monero-wallet-gui.exe"" ""%1"""

; Configure a custom URI scheme: Links starting with "moneroseed:" will start the GUI wallet exe with the URI as command-line parameter
; Used to easily hand over custom seed node info to the wallet, with an URI of the form "moneroseed://a.b.c.d:port"
Root: HKCR; Subkey: "moneroseed"; ValueType: "string"; ValueData: "URL:Monero Seed Node Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "moneroseed"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "moneroseed\DefaultIcon"; ValueType: "string"; ValueData: "{app}\monero-wallet-gui.exe,0"
Root: HKCR; Subkey: "moneroseed\shell\open\command"; ValueType: "string"; ValueData: """{app}\monero-wallet-gui.exe"" ""%1"""
