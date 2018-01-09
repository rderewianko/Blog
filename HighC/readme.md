# High Sierra has had numerous issues. I'll try and capture some of them here


## Rootless
Numerous blog posts detailing how there was no root password

## Undocumented changes to Kext
With these undocumented changes, av/next gen av providers have had a hard time ensuring compatibility. Carbon black for example had support up until 10.13.2 which changed issues.


## User Approved MDM
https://simplemdm.com/2017/11/01/user-approved-mdm-enrollment/


## fdsetup 
### recovery key overwrite - rdar://34633465
`fdesetup changerecovery -personal` with wrong password deletes recovery key
    https://openradar.appspot.com/34633465
### fdesetup changerecovery deletes recovery keys (10.13.1/17B46a) - rdar://35258997
http://www.openradar.me/radar?id=4943461371346944


## SecureToken issues with accounts - rdar://34874069 
Users created via cli tools do not receive SecureToken
https://openradar.appspot.com/34874069


## sysadminctl -secureTokenStatus allows null password - rdar://36163828 
https://openradar.appspot.com/radar?id=5009271813046272


## /var/empty/Library Issue
https://apple.stackexchange.com/questions/305627/what-is-causing-high-sierra-to-forget-where-my-home-directory-is


## HFS+ gets converted to APFS by FileVault
"also, neat (but dumb) 10.13 bug i just encountered: if you encrypt an existing HFS+ external drive, the OS converts it to APFS, then encrypts. even for time machine drives, which should remain HFS+."
https://macadmins.slack.com/archives/G4KM2NGDN/p1513961143000428
