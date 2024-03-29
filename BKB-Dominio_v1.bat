@echo off
cls

:: Obtém a largura atual da janela
for /F "usebackq tokens=2* delims=:" %%a in (`mode con ^| findstr /C:"Columns"`) do (
  set /a "window_width=%%a"
)
color 0E
cls
mode con: lines=30 cols=90


TITLE BURGER KING - JOIN DOMAIN SCRIPT

REM Solicitar privilégios de administrador
echo 			  #################################
echo 			  #                               #
echo 			  #     Burger King / Popeyes     #
echo 			  #       Join Domain Script      #
echo 			  #             v1.1              #
echo 			  #                               #
echo 			  #################################
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM Definir DNS primário e secundário
set dnsPrimary=10.255.0.110
set dnsSecondary=8.8.8.8


REM Verificar a versão atual do script no GitHub
setlocal EnableDelayedExpansion
set "versionURL=https://raw.githubusercontent.com/zVictorHG/RPA_LabTest/main/version.txt"
for /F %%I in ('curl.exe --silent %versionURL%') do set "latestVersion=%%I"

REM Comparar a versão atual com a versão mais recente
if "%latestVersion%" neq "1.0" (
  echo Nova versao disponivel!
  echo Iniciando download...
  REM Realizar o download do novo script do GitHub
  set "scriptURL=https://raw.githubusercontent.com/zVictorHG/RPA_LabTest/main/BKB-Dominio_v1.bat"
  curl.exe --silent --output script_new.bat %scriptURL%

  REM Substituir o script atual pelo novo script
  move /y script_new.bat BKB-Dominio_v1.bat

  REM Reabrir o script após a substituição
  call BKB-Dominio_v1.bat
) else (
  echo Voce possui a versao mais recente.
)

pause


REM Solicitar novo nome do hostname
echo.
echo 	    Lembrete: O novo hostname deve seguir o padrao dos restaurantes!
echo.
echo .                                                                                       .
echo #########################################################################################
echo # Exemplo 1: Se o restaurante for Burger King, o hostname deve ser 'GER+NUMERO DA LOJA' #
echo # Exemplo 2: Se o restaurante for Popeyes, o hostname deve ser 'PLK+NUMERO DA LOJA'     #
echo # Exemplo Resultado: Restaurante 14569, Burger King: GER14569 / Popeyes: PLK14569       #
echo #########################################################################################
echo .                                                                                       .
echo.
REM Exibir o hostname atual
echo HOSTNAME ATUAL: %COMPUTERNAME%
echo.

set /p newHostname="DIGITE O NOVO HOSTNAME: "

REM Renomear o computador usando o PowerShell
powershell.exe -Command "Rename-Computer -NewName '%newHostname%' -Force"

REM Exibir o novo nome do computador
echo.
echo # NOVO NOME DO COMPUTADOR: %newHostname%

echo .                                                                            .
echo #########################################################################################
echo # INFO 1: Nao deixe nenhum campo vazio, independente que ja esteja na numeracao correta,#
echo # ATENCAO: Ignorar a orientacao 'INFO 1' resultara no crash do script.                  #
echo #########################################################################################
echo .                                                                            .
echo.

REM Exibir informações de rede atuais
echo                    # INFORMACOES DE REDE ATUAIS #
echo.

REM Obter informações de rede usando o comando ipconfig
ipconfig | findstr /i "IPv4"
ipconfig | findstr /i "Subnet Sub-Rede"
ipconfig | findstr /i "Gateway"
echo.

REM Solicitar novo endereço IP
set /p newIP="DIGITE O NOVO ENDERECO IP: "
set /p subnetMask="DIGITE A NOVA MASCARA DE REDE: "
set /p gateway="DIGITE O GATEWAY: "

REM Configurar o endereço IP usando o comando netsh
netsh interface ipv4 set address name="Ethernet" static %newIP% %subnetMask% %gateway% 1

REM Configurar os servidores DNS usando o comando netsh
>nul netsh interface ipv4 set dns name="Ethernet" static %dnsPrimary% primary
>nul netsh interface ipv4 add dns name="Ethernet" %dnsSecondary% index=2


REM Win Defender
echo 1. Desabilitando o Windows Defender...

REM Desativar o Windows Defender permanentemente
>nul reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1

REM Firewall verbose
echo 2. Alterando configuracoes do firewall...

REM Desativar o Firewall do Windows permanentemente
>nul reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall /t REG_DWORD /d 0 /f
>nul reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v EnableFirewall /t REG_DWORD /d 0 /f
>nul reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v EnableFirewall /t REG_DWORD /d 0 /f

REM Habilitar o acesso via RDP
>nul reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

REM RDP Verbose
echo 3. Habilitando acesso remoto via RDP...


REM Adicionar a máquina ao domínio usando o PowerShell
powershell.exe -Command "$password = ConvertTo-SecureString -String '1' -AsPlainText -Force; Add-Computer -DomainName 'bkblojas.local' -Credential 'bkblojas\micros' -PassThru"

echo Maquina inserida ao dominio 'BKBLOJAS.LOCAL'.

shutdown -r -f -t 10


pause
