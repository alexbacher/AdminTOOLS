@echo off 

:param_fenetre
title AdminTOOLS v2.1
mode con cols=101 lines=38
color 9F

:demande_UAC
:-------------------------------------
REM  -->  Verification des permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> Erreur vous ne possedez pas les droits admin
if '%errorlevel%' NEQ '0' (
    echo Verification des privileges administrateur
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:choix
cls
echo.
echo                   ################################################################
echo                   #                                                              #
echo                   #      #### ###  # # ### #   #   ###  ##   ##  #     ###       #
echo                   #      #  # #  # ###  #  ##  #    #  #  # #  # #    #          #
echo                   #      #### #  # # #  #  # # #    #  #  # #  # #     ##        #
echo                   #      #  # #  # # #  #  #  ##    #  #  # #  # #       #       #
echo                   #      #  # ###  # # ### #   #    #   ##   ##  #### ### v2.1   #
echo                   #                                                              #
echo                   ################################################################
echo.
echo                     ############################################################
echo                     #                                                          #     
echo                     #    ATTENTION:                                            #     
echo                     #    Ce logiciel affecte des parametres systeme            #
echo                     #                                                          #
echo                     ############################################################
echo.
echo Faites un choix :
echo 1.	Nettoyage des param reseau (Ne pas executer en IP fixe)
echo 2. 	DISM (Windows 8 et +)
echo 3. 	SFC  (Windows 7 et -)
echo 4.	Sur quel serveur de domaine je suis ?
echo 5.	CHKDSK disque systeme
echo 6.	Reparer l'erreur CredSSP (Erreur connexion RDP)
echo 7. 	Desactiver/Activer cortana (Jusqu'a version 1809)
echo 8.	Recuperer le numero de serie du poste
echo 9.	Redemarrer et nettoyer le spouleur d'impression
echo 10.	Nettoyer fichier CBS.log
echo 11.	Redemarrer la carte reseau
echo 12.	Nettoyage serveur (sans Exchange)
echo 13.	Nettoyage serveur SBS (avec Exchange)
echo 14.	Installer la suite logicielle essentielle (Adobe Reader, Flash, Java, Chrome, Firefox, 7zip)
echo 15.	Lancer Ccleaner (Nettoyage poste)
echo 16.	Lancer Crystal Disk Info (Test disque dur)
echo 20.	Quitter
echo.
set /p choix=
if %choix%==1 	goto netpurge
if %choix%==2 	goto DISM
if %choix%==3 	goto SFC
if %choix%==4 	goto domain
if %choix%==5 	goto chkdsk
if %choix%==6 	goto credssp
if %choix%==7 	goto cortana
if %choix%==8 	goto wmic
if %choix%==9 	goto spooler
if %choix%==10	goto CBS_purge
if %choix%==11 	goto reboot_net
if %choix%==12 	goto nett_srv_non_exch
if %choix%==13 	goto nett_srv_sbs_exch
if %choix%==14	goto install_pack_software
if %choix%==15	goto ccleaner_choco
if %choix%==16	goto choco_crystal
if %choix%==20 	goto stop
:netpurge
cls
	cd c:\ 
echo Demarrage du FlushDNS
	@echo off 
	ipconfig /flushdns
echo Ok.
echo.
echo Demarrage de WinSock
	@echo off 
	netsh winsock reset catalog
echo.
echo Demarrage de ARPcache
	@echo off 
	netsh interface ip delete arpcache
echo Ok.
echo.
echo Nettoyage du fichier log
	@echo off 
	netsh int ip reset c:resetlog.txt
echo Ok.
echo.
echo NetPURGE OK
echo.
echo Pensez a redemarrer votre ordinateur..
echo.
echo ######################################
echo.
pause
goto choix

: reboot_net
echo redemarrage carte reseau (release/renew)
	@echo off
	ipconfig /release
	ipconfig /renew
echo.
echo redemarrage OK
echo.
echo ######################################
echo.
pause
goto choix

:DISM
cls
	DISM.exe /Online /Cleanup-image /Restorehealth
	sfc /scannow
echo DISM et SFC OK
echo.
echo Pensez a redemarrer votre ordinateur..
echo.
echo ######################################
echo.
pause
goto choix

:SFC
cls
	sfc /scannow
echo SFC OK
echo.
echo Pensez a redemarrer votre ordinateur..
echo.
echo ######################################
echo.
pause
goto choix
:domain
cls
echo le serveur de domaine est:
@echo off
echo %logonserver%
echo.
echo ######################################
echo.
pause
goto choix
:chkdsk
cls
	chkdsk /f c:
echo.
echo ######################################
echo.
pause
goto choix

:credssp
cls
@echo off
	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" /f /v AllowEncryptionOracle /t REG_DWORD /d 2
echo Vous pouvez a present vous connecter a votre serveur
echo.
echo ######################################
echo.
pause
goto choix

:cortana
cls
echo Faites un choix :
echo 1.	Desactiver Cortana
echo 2. 	Activer Cortana
echo 3. 	Annuler et revenir au menu
set /p cortanachoix=
if %cortanachoix%==1 goto cortanadel
if %cortanachoix%==2 goto cortanaback
if %cortanachoix%==3 goto choix

:cortanadel
cls
echo Creation de la cle Windows Search...
echo.
echo Ajout de la valeur DWORD 32 Bits AllowCortana...
echo.
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 00000000 /f
echo Cortana est a present inactif
echo.
echo Redemarrage de l'explorateur de fichiers
	@echo off
	TASKKILL /F /IM "explorer.exe"
	explorer
echo.
echo Pensez a redemarrer votre ordinateur..
echo.
echo ######################################
echo.
pause
goto choix

:cortanaback
cls
echo Suppression de la cle Windows Search...
echo.
echo Suppression de la valeur DWORD 32 Bits AllowCortana...
echo.
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
echo Cortana est a present actif
echo.
echo Redemarrage de l'explorateur de fichiers
	@echo off
	TASKKILL /F /IM "explorer.exe"
	explorer
echo.
echo Pensez a redemarrer votre ordinateur..
echo.
echo ######################################
echo.
pause
goto choix

:wmic
cls
	@echo off
	wmic bios get serialnumber
echo.
pause
goto choix

:spooler
cls
echo Arret du spouleur d'impression
	@echo off
	net stop spooler
echo attente...
	@echo off
	ping 127.0.0.1 -n 5 > NUL 2>&1
echo.
echo Nettoyage de la file d'impression
	del %systemroot%\System32\spool\printers\* /Q /F /S
echo nettoyage OK
echo.
echo Demarrage du spouleur d'impression
	@echo off
	net start spooler
echo.
	ping 127.0.0.1 -n 5 > NUL 2>&1
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:install_pack_software
cls
echo info : voici les paquets qui vont etre installes
echo 	- Adobe Reader
echo 	- Flash Player
echo 	- Java
echo 	- Google Chrome
echo 	- Firefox
echo 	- 7-Zip
echo.
echo Verification de la présence de Chocolatey...
@echo off
if exist "C:\ProgramData\chocolatey\choco.exe" goto install_pack_software_OK
goto install_pack_software_NOK

:install_pack_software_OK
cls
echo installation de adobe reader
	@echo off
	choco install -y --force adobereader
echo Install OK

cls
echo installation de flash player
	@echo off
	choco install -y --force flashplayerplugin
echo Install OK

echo installation de java
	@echo off
	choco install -y --force javaruntime
echo Install OK

cls
echo installation de chrome
	@echo off
	choco install -y --force googlechrome
echo Install OK

cls
echo installation de firefox
	@echo off
	choco install -y --force firefox
echo Install OK

cls
echo installation de 7zip
	@echo off
	choco install -y --force 7zip.install
echo Install OK

cls
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:install_pack_software_NOK
cls
	echo Installation de Chocolatey
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cls
echo installation de adobe reader
	@echo off
	choco install -y --force adobereader
echo Install OK

cls
echo installation de flash player
	@echo off
	choco install -y --force flashplayerplugin
echo Install OK

cls
echo installation de chrome
	@echo off
	choco install -y --force googlechrome
echo Install OK

cls
echo installation de firefox
	@echo off
	choco install -y --force firefox
echo Install OK

cls
echo installation de 7zip
	@echo off
	choco install -y --force 7zip.install
echo Install OK

cls
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:ccleaner_choco
cls
echo Verification de la présence de Chocolatey...
@echo off
if exist "C:\ProgramData\chocolatey\choco.exe" goto ccleaner_choco_OK
goto ccleaner_choco_NOK

:ccleaner_choco_OK
cls
	choco install -y --force ccleaner
cls
echo Install OK. Demarrage de Ccleaner
	start "cc"	"C:\Program Files\CCleaner\CCleaner64.exe"
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:ccleaner_choco_NOK
cls
	echo Installation de Chocolatey
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cls
echo installation de ccleaner
@echo off
choco install -y --force ccleaner
echo Install OK

cls
echo Install OK. Demarrage de Ccleaner
start "cc"	"C:\Program Files\CCleaner\CCleaner64.exe"
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:choco_crystal
cls
echo Verification de la présence de Chocolatey...
@echo off
if exist "C:\ProgramData\chocolatey\choco.exe" goto choco_crystal_OK
goto choco_crystal_NOK

:choco_crystal_OK
choco install -y --force crystaldiskinfo
cls
echo Install OK. Demarrage de Crystal Disk Info
start "cdinfo"	"C:\ProgramData\chocolatey\lib\crystaldiskinfo.portable\tools\DiskInfo64.exe"
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:choco_crystal_NOK
cls
	echo Installation de Chocolatey
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cls
echo installation de Crystal Disk Info
@echo off
choco install -y --force crystaldiskinfo
echo Install OK

cls
echo Install OK. Demarrage de Crystal Disk Info
start "cdinfo"	"C:\ProgramData\chocolatey\lib\crystaldiskinfo.portable\tools\DiskInfo64.exe"
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:CBS_purge
cls
echo Arret du service TrustedInstaller
	@echo off
	sc stop TrustedInstaller
	@echo off
	ping 127.0.0.1 -n 5 > NUL 2>&1

echo.
echo Suppression du fichier CBS.log
	del /F /Q %windir%\Logs\CBS\CBS.log

echo Demarrage du service TrustedInstaller
	@echo off
	sc start TrustedInstaller
	@echo off
	ping 127.0.0.1 -n 5 > NUL 2>&1

cls
echo Nettoyage CBS.log Ok 
echo.
echo Le service TrustedInstaller en cours de demarrage...
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:nett_srv_non_exch
cls
del C:\ProgramData\Microsoft\Windows\WER\ReportQueue\ /s /q
del c:\windows\softwaredistribution\download\ /s /q
del "c:\windows\system32\winevt\logs\Microsoft-Windows-Server Infrastructure Licensing*%4Debug.etl.*"
del C:\Windows\Temp\ /s /q
del C:\Windows\Prefetch\ /s /q
del c:\inetpub\logs\logfiles\ /s /q
del c:\windows\system32\certlog\*.log /s /q
rd /s /q c:\$Recycle.Bin
DISM /online /Cleanup-Image /SpSuperseded
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:nett_srv_sbs_exch
cls
del C:\ProgramData\Microsoft\Windows\WER\ReportQueue\ /s /q
del c:\windows\softwaredistribution\download\ /s /q
del "c:\windows\system32\winevt\logs\Microsoft-Windows-Server Infrastructure Licensing*%4Debug.etl.*"
del C:\Windows\Temp\ /s /q
del C:\Windows\Prefetch\ /s /q
net stop "datacollectorsvc"
cd "C:\Program Files\Windows Small Business Server\Logs\MonitoringServiceLogs\"
del *.log /s /q
net start "datacollectorsvc"

net stop "pop3connector"
cd "C:\Program Files\Windows Small Business Server\Logs\pop3connector\" 
del *.log /s /q
net start "pop3connector"
rd /s c:\$Recycle.Bin
DISM /online /Cleanup-Image /SpSuperseded
echo.
echo Processus termine
echo.
echo ######################################
echo.
pause
goto choix

:stop
cls
color 1F
mode con cols=80 lines=19
echo.
echo         ################################################################
echo         #                                                              #
echo         #      #### ###  # # ### #   #   ###  ##   ##  #     ###       #
echo         #      #  # #  # ###  #  ##  #    #  #  # #  # #    #          #
echo         #      #### #  # # #  #  # # #    #  #  # #  # #     ##        #
echo         #      #  # #  # # #  #  #  ##    #  #  # #  # #       #       #
echo         #      #  # ###  # # ### #   #    #   ##   ##  #### ### v2.1   #
echo         #                                                              #
echo         ################################################################
echo.
echo           ############################################################
echo           #                                                          #     
echo           #             Merci d'avoir utilise AdminTOOLS             #     
echo           #             By. Alex BACHER [alexbacher.fr]              #
echo           #                                                          #
echo           ############################################################
@echo off
ping 127.0.0.1 -n 3 > NUL 2>&1
exit