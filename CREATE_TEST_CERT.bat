rem TODO find makecert.exe
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x86\makecert.exe" -r -pe -ss PrivateCertStore -n CN=Windows(TEST) -eku 1.3.6.1.5.5.7.3.3 Test.cer

rem CertMgr /add Test.cer /s /r localMachine root
rem certmgr -add Test.cer -s -r localMachine TRUSTEDPUBLISHER