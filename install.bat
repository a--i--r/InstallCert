@echo off

rem -- カレントディレクトリを基準とする
cd /d %~dp0

rem -- バッチの実行結果をログとして出力する
cmd.exe /c _install_cert.bat > result.log 2>&1