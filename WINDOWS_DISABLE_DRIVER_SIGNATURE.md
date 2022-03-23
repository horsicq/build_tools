Disable device driver signing in Windows
=====

Before setting BCDEdit options you might need to disable or suspend **BitLocker** and **Secure Boot** on the computer.

- To disable device driver signing, type **BCDEDIT /set nointegritychecks ON** then press **Enter**
- To enable device driver signing, type **BCDEDIT /set nointegritychecks OFF** then press **Enter**

