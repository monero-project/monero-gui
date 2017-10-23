; Monero Helium Hydra GUI Wallet Installer for Windows
; Copyright (c) 2014-2017, The Monero Project
; See LICENSE

[Setup]
AppName=Monero GUI Wallet
; For InnoSetup this is the property that uniquely identifies the application as such
; Thus it's important to keep this stable over releases
; With a different "AppName" InnoSetup would treat a mere update as a completely new application and thus mess up

AppVersion=0.11.1.0
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
Source: "ReadMe.htm"; DestDir: "{app}"; Flags: comparetimestamp
Source: "FinishImage.bmp"; Flags: dontcopy

; Monero GUI wallet
Source: "bin\monero-wallet-gui.exe"; DestDir: "{app}"; Flags: comparetimestamp

; Monero GUI wallet log file
; The GUI wallet does not have the "--log-file" command-line option of the CLI wallet and insists to put the .log beside the .exe
; so pre-create the file and give the necessary permissions to the wallet to write into it
Source: "monero-wallet-gui.log"; DestDir: "{app}"; Flags: comparetimestamp; Permissions: users-modify

; Monero CLI wallet
Source: "bin\monero-wallet-cli.exe"; DestDir: "{app}"; Flags: comparetimestamp

; Monero wallet RPC interface implementation
Source: "bin\monero-wallet-rpc.exe"; DestDir: "{app}"; Flags: comparetimestamp

; Monero daemon
Source: "bin\monerod.exe"; DestDir: "{app}"; Flags: comparetimestamp

; Monero daemon wrapped in a batch file that stops before the text window closes, to see any error messages
Source: "monero-daemon.bat"; DestDir: "{app}"; Flags: comparetimestamp;

; Monero blockchain utilities
Source: "bin\monero-blockchain-export.exe"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\monero-blockchain-import.exe"; DestDir: "{app}"; Flags: comparetimestamp

; was present in 0.10.3.1, not present anymore in 0.11.1.0
; Source: "bin\monero-utils-deserialize.exe"; DestDir: "{app}"; Flags: comparetimestamp

; Various .qm files for translating the wallet UI "on the fly" into all supported languages
Source: "bin\translations\*"; DestDir: "{app}\translations"; Flags: recursesubdirs comparetimestamp

; Core Qt runtime
Source: "bin\Qt5Core.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Gui.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Multimedia.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5MultimediaQuick_p.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Network.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Qml.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Quick.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Svg.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5Widgets.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\Qt5XmlPatterns.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Qt QML elements like the local files selector "FolderListModel" and "Settings"
Source: "bin\Qt\*"; DestDir: "{app}\Qt"; Flags: recursesubdirs comparetimestamp

; Qt audio support
Source: "bin\audio\*"; DestDir: "{app}\audio"; Flags: recursesubdirs comparetimestamp

; Qt bearer / network connection management
Source: "bin\bearer\*"; DestDir: "{app}\bearer"; Flags: recursesubdirs comparetimestamp

; Qt Windows platform plugin	
Source: "bin\platforms\qwindows.dll"; DestDir: "{app}\platforms"; Flags: comparetimestamp

; Qt support for SVG icons	
Source: "bin\iconengines\*"; DestDir: "{app}\iconengines"; Flags: recursesubdirs comparetimestamp

; Qt support for various image formats (JPEG, BMP, SVG etc)	
Source: "bin\imageformats\*"; DestDir: "{app}\imageformats"; Flags: recursesubdirs comparetimestamp

; Qt multimedia support	
Source: "bin\QtMultimedia\*"; DestDir: "{app}\QtMultimedia"; Flags: recursesubdirs comparetimestamp
Source: "bin\mediaservice\*"; DestDir: "{app}\mediaservice"; Flags: recursesubdirs comparetimestamp

; Qt support for "m3u" playlists
; candidate for elimination? Don't think the GUI wallet needs such playlists	
Source: "bin\playlistformats\*"; DestDir: "{app}\playlistformats"; Flags: recursesubdirs comparetimestamp

; Qt graphical effects as part of the core runtime, effects like blurring and blending
Source: "bin\QtGraphicalEffects\*"; DestDir: "{app}\QtGraphicalEffects"; Flags: recursesubdirs comparetimestamp

; Some more Qt graphical effects
; "private" as a name for this directory looks a little strange. Historical reasons?	
Source: "bin\private\*"; DestDir: "{app}\private"; Flags: recursesubdirs comparetimestamp

; Qt QML files
Source: "bin\QtQml\*"; DestDir: "{app}\QtQml"; Flags: recursesubdirs comparetimestamp

; Qt Quick files
Source: "bin\QtQuick\*"; DestDir: "{app}\QtQuick"; Flags: recursesubdirs comparetimestamp
Source: "bin\QtQuick.2\*"; DestDir: "{app}\QtQuick.2"; Flags: recursesubdirs comparetimestamp

; Qt Quick 2D Renderer fallback for systems / environments with "low-level graphics" i.e. without 3D support
Source: "bin\scenegraph\*"; DestDir: "{app}\scenegraph"; Flags: recursesubdirs comparetimestamp
Source: "bin\start-low-graphics-mode.bat"; DestDir: "{app}"; Flags: comparetimestamp

; Mesa, open-source OpenGL implementation; part of "low-level graphics" support
Source: "bin\opengl32sw.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Left out subdirectory "qmltooling" with the Qt QML debugger: Probably not relevant in an end-user package

; Microsoft Direct3D runtime
Source: "bin\D3Dcompiler_47.dll"; DestDir: "{app}"; Flags: comparetimestamp

; bzip2 support
Source: "bin\libbz2-1.dll"; DestDir: "{app}"; Flags: comparetimestamp

; ANGLE ("Almost Native Graphics Layer Engine") support, as used by Qt
Source: "bin\libEGL.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\libGLESV2.dll"; DestDir: "{app}"; Flags: comparetimestamp

; FreeType font engine, as used by Qt
Source: "bin\libfreetype-6.dll"; DestDir: "{app}"; Flags: comparetimestamp

; GCC runtime, x64 version
Source: "bin\libgcc_s_seh-1.dll"; DestDir: "{app}"; Flags: comparetimestamp

; GLib, low level core library e.g. for GNOME and GTK+
; Really needed under Windows?
Source: "bin\libglib-2.0-0.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Graphite font support
; Really needed?
Source: "bin\libgraphite2.dll"; DestDir: "{app}"; Flags: comparetimestamp

; HarfBuzz OpenType text shaping engine
; Really needed?
Source: "bin\libharfbuzz-0.dll"; DestDir: "{app}"; Flags: comparetimestamp

; LibIconv, conversions between character encodings
Source: "bin\libiconv-2.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Part of cygwin? Needed by Qt somehow?
Source: "bin\libicudt57.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\libicuin57.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\libicuuc57.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Library for native language support, part of GNU gettext
Source: "bin\libintl-8.dll"; DestDir: "{app}"; Flags: comparetimestamp

; JasPer, support for JPEG-2000
; was present in 0.10.3.1, not present anymore in 0.11.1.0
; Source: "bin\libjasper-1.dll"; DestDir: "{app}"; Flags: comparetimestamp

; libjpeg, C library for reading and writing JPEG image files
Source: "bin\libjpeg-8.dll"; DestDir: "{app}"; Flags: comparetimestamp

; Little CMS, color management system
Source: "bin\liblcms2-2.dll"; DestDir: "{app}"; Flags: comparetimestamp

; XZ Utils, LZMA compression library
Source: "bin\liblzma-5.dll"; DestDir: "{app}"; Flags: comparetimestamp

; MNG / Portable Network Graphics ("animated PNG") 
Source: "bin\libmng-2.dll"; DestDir: "{app}"; Flags: comparetimestamp

; PCRE, Perl Compatible Regular Expressions
Source: "bin\libpcre-1.dll"; DestDir: "{app}"; Flags: comparetimestamp
Source: "bin\libpcre16-0.dll"; DestDir: "{app}"; Flags: comparetimestamp

; libpng, the official PNG reference library
Source: "bin\libpng16-16.dll"; DestDir: "{app}"; Flags: comparetimestamp

; libstdc++, GNU Standard C++ Library
Source: "bin\libstdc++-6.dll"; DestDir: "{app}"; Flags: comparetimestamp

; LibTIFF, TIFF Library and Utilities
Source: "bin\libtiff-5.dll"; DestDir: "{app}"; Flags: comparetimestamp

; C++ threading support
Source: "bin\libwinpthread-1.dll"; DestDir: "{app}"; Flags: comparetimestamp

; zlib compression library
Source: "bin\zlib1.dll"; DestDir: "{app}"; Flags: comparetimestamp


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
    width: Integer;
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
  s := s + '. As this will need more than 30 GB of free space, you may want to use a folder on a different drive.';
  s := s + ' If yes, specify that folder here.';

  BlockChainDirPage := CreateInputDirPage(wpSelectDir,
    'Select Blockchain Directory', 'Where should the blockchain be installed?',
    s,
    False, '');
  BlockChainDirPage.Add('');

  BlockChainDirPage.Values[0] := GetPreviousData('BlockChainDir', '');
  if BlockChainDirPage.Values[0] = '' then begin
    // Unfortunately 'TInputDirWizardDirPage' does not allow empty field
    BlockChainDirPage.Values[0] := blockChainDefaultDir;
  end;
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
Name: "{group}\GUI Wallet"; Filename: "{app}\monero-wallet-gui.exe"
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
Name: "{group}\Utilities\x (Check Default Wallet Folder)"; Filename: "{win}\Explorer.exe"; Parameters: "{userdocs}\Monero\wallets"
Name: "{group}\Utilities\x (Check GUI Wallet Log)"; Filename: "Notepad"; Parameters: "{app}\monero-wallet-gui.log"
Name: "{group}\Utilities\x (Try Daemon, Exit Confirm)"; Filename: "{app}\monero-daemon.bat"
Name: "{group}\Utilities\x (Try GUI Wallet Low Graphics Mode)"; Filename: "{app}\start-low-graphics-mode.bat"
Name: "{group}\Utilities\x (Try Kill Daemon)"; Filename: "Taskkill.exe"; Parameters: "/IM monerod.exe /T /F"

; Desktop icons, optional with the help of the "Task" section
Name: "{userdesktop}\GUI Wallet"; Filename: "{app}\monero-wallet-gui.exe"; Tasks: desktopicon


[Registry]
; Store any special flags for the daemon in the registry location where the GUI wallet will take it from
; So if the wallet is used to start the daemon instead of the separate icon the wallet will pass the correct flags
; Side effect, mostly positive: The uninstaller will clean the registry
Root: HKCU; Subkey: "Software\monero-project"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\monero-project\monero-core"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\monero-project\monero-core"; ValueType: string; ValueName: "daemonFlags"; ValueData: {code:DaemonFlags};

