If Exist %USERPROFILE%\AppData\Roaming\1C\1Cv82 (
rem ������� ��� �����
Del /F /Q %USERPROFILE%\AppData\Roaming\1C\1Cv82\*.*
Del /F /Q %USERPROFILE%\AppData\Local\1C\1Cv82\*.*

rem ������� ��� ��������
for /d %%i in (�%USERPROFILE%\AppData\Roaming\1C\1Cv82\*�) do rmdir /s /q �%%i�
for /d %%i in (�%USERPROFILE%\AppData\Local\1C\1Cv82\*�) do rmdir /s /q �%%i�
)