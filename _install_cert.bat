@echo off

echo **** �ؖ����C���X�g�[������: %date% %time%

SETLOCAL enabledelayedexpansion

rem -- SAMPLE1�ؖ����̃t�@�C����
set SAMPLE1_CERT_NAME=testdkbudget.japaneast.cloudapp.azure.com.cer
set LOG_FILE=result.log

rem -- SAMPLE1�ؖ����̃V���A���ԍ�, �T�u�W�F�N�g
set SAMPLE1_CERT_SERIAL=00a371061ed991a85a
set SAMPLE1_CERT_SERIAL_SUBJECT="testdkbudget.japaneast.cloudapp.azure.com"

rem -- �J�����g�f�B���N�g������Ƃ���
cd /d %~dp0

:checkMandatoryLevel
rem --- ���Ǘ��҂Ƃ��Ď��s����Ă��邩�m�F START
for /f "tokens=1 delims=," %%i in ('whoami /groups /FO CSV /NH') do (
    if "%%~i"=="BUILTIN\Administrators" set ADMIN=yes
    if "%%~i"=="Mandatory Label\High Mandatory Level" set ELEVATED=yes
)


echo ADMIN=%ADMIN%
echo ELEVATED=%ELEVATED%

if "%ADMIN%" neq "yes" (
    rem -- Administrators�O���[�v�łȂ��i���[�J�����[�U�̏ꍇ�j
    echo �J�����g���[�U�ɂ̂ݏؖ������C���X�g�[�����܂��B

    rem --- �ؖ����R�s�[SAMPLE1�m�F����
    CALL :checkUserCertificationSAMPLE1

    goto exit1
)
if "%ELEVATED%" neq "yes" (
    rem -- (�v���Z�X�����i����Ă��Ȃ�) Admin�������胆�[�U���ʏ���s�����ꍇ
    echo ���̃t�@�C���͊Ǘ��Ҍ����ł̎��s���K�v�ł�
    echo ���i���s���܂��̂ŁA���΂炭���҂���������

    goto runas
)
rem --- ���Ǘ��҂Ƃ��Ď��s����Ă��邩�m�F END

:admins
    rem --- ���Ǘ��҂Ƃ��Ď��s�������R�}���h START

    rem --- �ؖ����R�s�[����
    echo ���[�J���R���s���[�^�ɏؖ������C���X�g�[�����܂��B
    CALL :copyCertification

    rem --- ���Ǘ��҂Ƃ��Ď��s�������R�}���h END
    goto exit1

:runas

    if "%1" == "" (
        rem --- �����Ȃ��̂��߁A���Ǘ��҂Ƃ��čĎ��s
        powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process %~f0 -Verb runas -ArgumentList '>> %~dp0\%LOG_FILE% 2>&1'"

    ) else (
        rem --- ��������̂��߁A���łɎ��g���Ď��s���Ă���B
        rem --- �J�����g���[�U�ɂ̂݃C���X�g�[��
        echo �Ǘ��҂ւ̏��i�Ɏ��s���܂����B�J�����g���[�U�ɂ̂ݏؖ������C���X�g�[�����܂��B

        rem --- �ؖ����R�s�[SAMPLE1�m�F����
        CALL :checkUserCertificationSAMPLE1
    )


goto exit1

rem --- ���[�J���R���s���[�^�p�R�s�[�����T�u���[�`��
:copyCertification

    ECHO �R�s�[�������{: �ؖ���1

    rem -- SAMPLE1�ؖ����������㏑���C���X�g�[������
    rem -- ���[�J�� �R���s���[�^�[:�M�����ꂽ���[�g�ؖ��@��
    certutil -addstore -f ROOT %SAMPLE1_CERT_NAME%

    exit /B


rem --- �J�����g���[�U�p�R�s�[SAMPLE1�m�F�����T�u���[�`��
:checkUserCertificationSAMPLE1

    rem --- ���[�J���}�V���Ɋ���SAMPLE1�ؖ����������Ă��邩
    verify >nul
    certutil -verifystore ROOT %SAMPLE1_CERT_SERIAL% | findstr %SAMPLE1_CERT_SERIAL_SUBJECT%

    rem -- ������Ȃ�����(�G���[)�̏ꍇ�A�R�s�[
    IF '%ERRORLEVEL%'=='1' (
        echo "�ؖ������Ȃ��̂ŃC���X�g�[�����܂�"
        goto copyUserCertificationSAMPLE1
    )
    rem -- ��������(����)�̏ꍇ�A�X�L�b�v
    IF '%ERRORLEVEL%'=='0' (
        echo "�ؖ��������������̂ŃX�L�b�v���܂�"
        goto exit1
    )

    exit /B


rem --- �J�����g���[�U�pSAMPLE1�ؖ����R�s�[�T�u���[�`��
:copyUserCertificationSAMPLE1


    ECHO �R�s�[�������{: SAMPLE1�ؖ���

    rem -- SAMPLE1�ؖ������C���X�g�[������
    rem -- �J�����g���[�U:�M�����ꂽ���[�g�ؖ��@��
    certutil -user -addstore -f ROOT %SAMPLE1_CERT_NAME%

    rem -- ������Ȃ�����(�G���[)�̏ꍇ�A�R�s�[
    IF '%ERRORLEVEL%'=='1' (
        echo "�ؖ����̃C���X�g�[���Ɏ��s���܂���"
        goto exit1
    )
    rem -- ��������(����)�̏ꍇ�A�X�L�b�v
    IF '%ERRORLEVEL%'=='0' (
        echo "�ؖ����̃C���X�g�[�����m�F���܂���"
        goto exit1
    )

    exit /B


:exit1
echo **** �ؖ����C���X�g�[�������I��: %date% %time%
endlocal

exit