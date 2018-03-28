# InstallCert
任意の証明書を信頼されたルート証明機関へインストールするバッチプログラム

## Requirements
検証環境: Windows10 64bit

- Windows Powershell

## Usage
1. 任意のディレクトリへ保存します
```
例: c:\Tools
```

2. インストールする証明書をバッチと同じディレクトリへ保存します
```
例: c:\Tools\InstallCert\sample.cer
```

3. エディタでインストールする証明書の設定をします
3.1. c:\Tools\InstallCert\_install_cert.bat の中を編集します
```
rem -- 8行目付近
set SAMPLE1_CERT_NAME=sample.cer

rem -- 12行目付近
set SAMPLE1_CERT_SERIAL=00a371061ed991a85a         <- cer ファイルを開いて中のシリアル番号を設定
set SAMPLE1_CERT_SERIAL_SUBJECT="sample.domain"    <- ドメイン名を設定
```

3.2. 編集したファイルを保存します

4. install.bat バッチを実行します
```
ダブルクリック　又は コマンドラインから実行
```

5. ログファイルを確認します
```
正常終了していればOKです
```

6. ブラウザで証明書エラーが出ないことを確認
```
各ブラウザでURLにアクセスして確認してください
```

## License
This software is released under the MIT License, see LICENSE.