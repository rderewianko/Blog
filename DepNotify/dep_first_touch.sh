#!/bin/bash
#
#First up! Even if the machine's sitting at a login prompt. Install DepNotify

jamf policy -event install_depnotify
jamf policy -event install_dockutil

#figure out when the dock is showing and start script! (I'm not too sure how this works...)
while true;	do
	myUser=$(whoami)
	dockcheck=`ps -ef | grep [/]System/Library/CoreServices/Dock.app/Contents/MacOS/Dock`
	echo "Waiting for file as: ${myUser}"
	sudo echo "Waiting for file as: ${myUser}" >> /var/log/jamf.log
	echo "regenerating dockcheck as ${dockcheck}."

	if [ ! -z "${dockcheck}" ]; then
		echo "Dockcheck is ${dockcheck}, breaking."
		break
	fi
	sleep 1
done

#Figure out who our user is
user=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')


#### Functions
#lets remove desktop icons!
su -l $user -c "defaults write /Users/$user/Library/Preferences/com.apple.finder InterfaceLevel simple"
killall Finder
su -l $user -c "/usr/local/bin/dockutil --remove all"

### Define Log Files file
depnotify_log="/var/tmp/depnotify.log"
log_path="/var/log/PI_DEP.log"
#create logger
function log (){
  datetime=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$datetime" - "$1" >> $log_path
}

#create depnotify log
function depnotify() {
	echo $1 >> $depnotify_log
	log "$1"
}


touch $log_path





#### SCRIPT

#log start time
start=$SECONDS

#Configure Dep notify
depnotify "Command: WindowStyle: NotMovable"
depnotify "Command: WindowStyle: ActivateOnStep"
depnotify "Command: WindowTitle: We're getting this Mac ready for you"
depnotify "Command: MainText: Hey there <company>! We're doing some initial tasks on your Mac to get you started. This should only take a few minutes, so sit back grab a ☕ and wait for the magic to happen. At the end this computer will reboot and ask you to login. \n \n Please do not close the computer or shut it down until we're finished."


#grab PI logo!
curl -o /var/tmp/yourlogo.icns <url for logo>
depnotify "Command: Image: /var/tmp/yourlogo.icns"

#Open DepNotify
/var/tmp/DepNotify.app/Contents/MacOS/DEPNotify &


log "process started"


log "starting tasks"
log "our user is $user"
depnotify "Command: Determinate: 12"
depnotify "Status: Setting Background"
jamf policy -event configure_background


depnotify "Status: Naming Machine"
log "flushing polciy history"
jamf flushPolicyHistory

log "providing username for recon"
jamf recon -endUsername "$user"

### adding for future touchbar support it's safe to assume they aren't running a 
# touchbar testing tool at this stage. 
if pgrep "TouchBarAgent"; then
    touch_bar="Yes"
else
	touch_bar="No"
fi

log "Does this mac have a touchbar?: $touch_bar"

#set the hostname

Model=$(system_profiler SPHardwareDataType | grep "Model Name" | cut -d " " -f9-)

if [ "$Model" == "MacBook Pro" ];
then
	computerName=$user'-r'
elif [ "$Model" == "MacBook Air" ];  then
	computerName=$user'-a'
elif [ "$Model" == "Mac mini" ];  then
	computerName=$user'-mini'
elif [ "$Model" == "iMac" ];  then
	computerName=$user'-i'
else
	computerName=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
fi

log "computer name is $computerName"

jamf setComputerName -name "$computerName"
/usr/sbin/scutil --set LocalHostName "$computerName"
/usr/sbin/scutil --set HostName "$computerName"
/usr/sbin/scutil --set ComputerName "$computerName"
/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "$computerName"
log "finished setting computer name"
log "setting sw update"

depnotify "Status: Configuring Software update"
# set softwareupdate schedule On
softwareupdate --schedule on


# install all updates with verbose output
#jamf policy -event dep_softwareupdate



depnotify "Status: Installing Crashplan"
#installing all the things!
jamf policy -event install_crashplansilently

depnotify "Status: Installing Firefox"
jamf policy -event install_firefox


depnotify "Status: Installing Google Chrome"
jamf policy -event install_googlechrome

depnotify "Status: Installing Slack"
jamf policy -event install_slack


depnotify "Status: Installing Security Software"

jamf policy -event install_CarbonBlack
jamf policy -event install_sep

depnotify "Status: Installing Masery Communicator"
jamf policy -event install_masergycommunicator

depnotify "Status: Installing Biba"
jamf policy -event install_biba


depnotify "Status: Setting up Dock"
jamf policy -event DEP

depnotify "Status: Installing Misc Config"
jamf policy -event depScripts

#jamf policy -event install_nomad
log "enabling encryption"

depnotify "Status: Rebooting Machine"
#log "jobs done telling machine to reboot in 1 min"

log "telling machine to install office"
defaults write /Library/Preferences/com.company.conf.plist "deploy_office" "yes"
touch /var/db/.DEP_Done
jamf recon
duration=$(( SECONDS - start ))

((sec=duration%60, duration/=60, min=duration%60, hrs=duration/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

log "process took $timestamp to finish"

#lets change finder back to a happy state...
su -l $user -c "defaults write /Users/$user/Library/Preferences/com.apple.finder InterfaceLevel standard"
#touching file for future purposes.

depnotify "Command: RestartNow:"
exit 0

