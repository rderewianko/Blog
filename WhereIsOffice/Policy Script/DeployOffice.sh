#!/bin/sh
########################################################################
# Created By: Ross Derewianko
#“WHAT ABOUT THE CARNY CODE?
# Creation Date: July 2017
# Last modified: July 16, 2017
# Brief Description: Deploy Office by Script
########################################################################


#Change this to whatever icon you'd prefer to load
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarAdvanced.icns"
#Change this to your policy event trigger
office_trigger="install_office2016"

##check for excel (agian just incase!)
if [[ -f "/Applications/Microsoft Excel.app/Contents/MacOS/Microsoft Excel" ]]; then
   	echo "Microsoft Office 2016 exists"
	echo "removing where is Office files"
	rm -rf "/Applications/Microsoft Office 2016/"
   	echo "using Jamf helper to notify the machine of install"
   	#put it in a variable beacuse we don't care about the output
	JamfHelper=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType hud -title "Install Finished" -description "Microsoft Office 2016 has finished installing on your Mac." -icon  "$icon" -button1 Okay -defaultButton 0) &
	exit 0
else
	echo "Office 2016 does not exist installing"
	jamf policy -event $office_trigger
	exit 0
fi
