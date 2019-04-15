@echo off

echo **** 証明書インストール処理: %date% %time%

SETLOCAL enabledelayedexpansion

rem -- SAMPLE1証明書のファイル名
set SAMPLE1_CERT_NAME=testdkbudget.japaneast.cloudapp.azure.com.cer
set LOG_FILE=result.log

rem -- SAMPLE1証明書のシリアル番号, サブジェクト
set SAMPLE1_CERT_SERIAL=00a371061ed991a85a
set SAMPLE1_CERT_SERIAL_SUBJECT="testdkbudget.japaneast.cloudapp.azure.com"

rem -- カレントディレクトリを基準とする
cd /d %~dp0

:checkMandatoryLevel
rem --- ▼管理者として実行されているか確認 START
for /f "tokens=1 delims=," %%i in ('whoami /groups /FO CSV /NH') do (
    if "%%~i"=="BUILTIN\Administrators" set ADMIN=yes
    if "%%~i"=="Mandatory Label\High Mandatory Level" set ELEVATED=yes
)


echo ADMIN=%ADMIN%
echo ELEVATED=%ELEVATED%

if "%ADMIN%" neq "yes" (
    rem -- Administratorsグループでない（ローカルユーザの場合）
    echo カレントユーザにのみ証明書をインストールします。

    rem --- 証明書コピーSAMPLE1確認処理
    CALL :checkUserCertificationSAMPLE1

    goto exit1
)
if "%ELEVATED%" neq "yes" (
    rem -- (プロセスが昇格されていない) Admin権限ありユーザが通常実行した場合
    echo このファイルは管理者権限での実行が必要です
    echo 昇格を行いますので、しばらくお待ちください

    goto runas
)
rem --- ▲管理者として実行されているか確認 END

:admins
    rem --- ▼管理者として実行したいコマンド START

    rem --- 証明書コピー処理
    echo ローカルコンピュータに証明書をインストールします。
    CALL :copyCertification

    rem --- ▲管理者として実行したいコマンド END
    goto exit1

:runas

    if "%1" == "" (
        rem --- 引数なしのため、★管理者として再実行
        powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process %~f0 -Verb runas -ArgumentList '>> %~dp0\%LOG_FILE% 2>&1'"

    ) else (
        rem --- 引数ありのため、すでに自身を再実行している。
        rem --- カレントユーザにのみインストール
        echo 管理者への昇格に失敗しました。カレントユーザにのみ証明書をインストールします。

        rem --- 証明書コピーSAMPLE1確認処理
        CALL :checkUserCertificationSAMPLE1
    )


goto exit1

rem --- ローカルコンピュータ用コピー処理サブルーチン
:copyCertification

    ECHO コピー処理実施: 証明書1

    rem -- SAMPLE1証明書を強制上書きインストールする
    rem -- ローカル コンピューター:信頼されたルート証明機関
    certutil -addstore -f ROOT %SAMPLE1_CERT_NAME%

    exit /B


rem --- カレントユーザ用コピーSAMPLE1確認処理サブルーチン
:checkUserCertificationSAMPLE1

    rem --- ローカルマシンに既にSAMPLE1証明書が入っているか
    verify >nul
    certutil -verifystore ROOT %SAMPLE1_CERT_SERIAL% | findstr %SAMPLE1_CERT_SERIAL_SUBJECT%

    rem -- 見つからなかった(エラー)の場合、コピー
    IF '%ERRORLEVEL%'=='1' (
        echo "証明書がないのでインストールします"
        goto copyUserCertificationSAMPLE1
    )
    rem -- 見つかった(正常)の場合、スキップ
    IF '%ERRORLEVEL%'=='0' (
        echo "証明書が見つかったのでスキップします"
        goto exit1
    )

    exit /B


rem --- カレントユーザ用SAMPLE1証明書コピーサブルーチン
:copyUserCertificationSAMPLE1


    ECHO コピー処理実施: SAMPLE1証明書

    rem -- SAMPLE1証明書をインストールする
    rem -- カレントユーザ:信頼されたルート証明機関
    certutil -user -addstore -f ROOT %SAMPLE1_CERT_NAME%

    rem -- 見つからなかった(エラー)の場合、コピー
    IF '%ERRORLEVEL%'=='1' (
        echo "証明書のインストールに失敗しました"
        goto exit1
    )
    rem -- 見つかった(正常)の場合、スキップ
    IF '%ERRORLEVEL%'=='0' (
        echo "証明書のインストールを確認しました"
        goto exit1
    )

    exit /B


:exit1
echo **** 証明書インストール処理終了: %date% %time%
endlocal

exit