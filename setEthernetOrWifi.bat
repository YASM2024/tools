@echo off
setlocal enabledelayedexpansion

:: アダプター名
set "LAN=イーサネット"
set "WLAN=Wi-Fi"

:: 定数設定（ここを任意の値に変更する）
set "MASK=255.255.0.0"
set "GATEWAY=10.0.0.254"
set "DNS1=10.0.0.1"
set "DNS2=10.0.0.2"

:: 管理者権限のチェック
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 管理者権限で実行してください。プログラムを終了します...
    pause > null
    exit /b
)

:: ユーザー選択を表示
echo どちらの操作を行いますか？
echo 1. イーサネット⇒Wifi
echo 2. Wifi⇒イーサネット
set /p choice="選択してください (1 または 2): "

:: 操作の選択
if "%choice%"=="1" goto :EthernetToWifi
if "%choice%"=="2" goto :WifiToEthernet

echo 無効な選択肢です。終了します。
pause
exit /b

:: --- 有線 -> 無線の設定 ---
:EthernetToWifi
echo 有線LANの設定を無線LANに移行します...

:: 有線LANのIPアドレス取得
for /f "tokens=2 delims=:" %%A in ('netsh interface ip show config name^="%LAN%" ^| findstr /C:"IP アドレス"') do (
    set "IP=%%A"
)
:: 前後の空白を除去
set "IP=%IP: =%"

echo 検出されたIPアドレス: %IP%

:: 有線LANをDHCP化 & 無効化
echo 有線LANの設定をDHCPに変更中...
netsh interface ip set address "%LAN%" dhcp
netsh interface ip set dnsservers "%LAN%" dhcp
netsh interface set interface "%LAN%" admin=disable

:: 無線LANを有効化
echo 無線LANを有効化中...
netsh interface set interface "%WLAN%" admin=enable
timeout /t 3 >nul

:: 無線LANに静的設定を適用
echo 無線LANに静的IPを設定中...
netsh interface ip set address "%WLAN%" static %IP% %MASK% %GATEWAY%
netsh interface ip set dnsservers "%WLAN%" static %DNS1% primary
netsh interface ip add dnsservers "%WLAN%" %DNS2% index=2

echo 完了しました。
pause
exit /b

:: --- 無線 -> 有線の設定 ---
:WifiToEthernet
echo 無線LANの設定を有線LANに移行します...

:: 無線LANのIPアドレス取得
for /f "tokens=2 delims=:" %%A in ('netsh interface ip show config name^="%WLAN%" ^| findstr /C:"IP アドレス"') do (
    set "IP=%%A"
)
:: 前後の空白を除去
set "IP=%IP: =%"

echo 検出されたIPアドレス: %IP%

:: 無線LANをDHCP化 & 無効化
echo 無線LANの設定をDHCPに変更中...
netsh interface ip set address "%WLAN%" dhcp
netsh interface ip set dnsservers "%WLAN%" dhcp
netsh interface set interface "%WLAN%" admin=disable

:: 有線LANを有効化
echo 有線LANを有効化中...
netsh interface set interface "%LAN%" admin=enable
timeout /t 3 >nul

:: 有線LANに静的設定を適用
echo 有線LANに静的IPを設定中...
netsh interface ip set address "%LAN%" static %IP% %MASK% %GATEWAY%
netsh interface ip set dnsservers "%LAN%" static %DNS1% primary
netsh interface ip add dnsservers "%LAN%" %DNS2% index=2

echo 完了しました。
pause
exit /b
