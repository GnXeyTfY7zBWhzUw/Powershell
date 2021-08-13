
Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name Arrow -Value "${$HOME}\Downloads\HiddenCursor.cur"
$CSharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                 uint uiAction,
                 uint uiParam,
                 uint pvParam,
                uint fWinIni);
'@

$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo –PassThru
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)