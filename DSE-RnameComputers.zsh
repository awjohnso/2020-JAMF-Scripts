#!/bin/zsh

# Author: Andrew W. Johnson
# Date: Sometime End of April 2020.
# Version 1.00
# Organization: Stony Brook Univeristy/DoIT

# This script will rename the computers as they are enrolled into JAMF and then
# Kick off the base policies that need to run on the computers.


mySN=`/usr/sbin/ioreg -l | /usr/bin/awk '/IOPlatformSerialNumber/ { print $4;}' | /usr/bin/sed s/\"//g`
webdb=`/usr/bin/curl -s http://asu.campus.stonybrook.edu/byhost.csv | /usr/bin/egrep -i ${mySN}`

name=`/bin/echo ${webdb} | /usr/bin/cut -d "," -f 1`
SN=`/bin/echo ${webdb} | /usr/bin/cut -d "," -f 2`
ARD2=`/bin/echo ${webdb} | /usr/bin/cut -d "," -f 3`
lcName=`/bin/echo "${name}" | /usr/bin/tr '[:upper:]' '[:lower:]'`
org=`/bin/echo "${webdb}" | /usr/bin/cut -d "," -f 5`

if [ -z ${name} ]; then
	/bin/echo -n "Error! Can't find the information in the byhost file.          Setting name to: " >> /Library/Logs/DSE-RenameComputer.log
	name=${mySN}
	/bin/echo ${name} >> /Library/Logs/DSE-RenameComputer.log
else
	/bin/echo "         Setting name to: ${name}" >> /Library/Logs/DSE-RenameComputer.log
fi

if [ -z ${SN} ]; then
	echo -n "Error! Can't find the information in the byhost file. Setting Serial Number to: " >> /Library/Logs/DSE-RenameComputer.log
	SN=${mySN}
	/bin/echo ${SN} >> /Library/Logs/DSE-RenameComputer.log
else
	/bin/echo "Setting Serial Number to: ${SN}" >> /Library/Logs/DSE-RenameComputer.log
fi

if [ -z ${ARD2} ]; then
	/bin/echo -n "Error! Can't find the information in the byhost file.     Setting Asset Tag to: " >> /Library/Logs/DSE-RenameComputer.log
	ARD2="Asset-N/A"
	/bin/echo ${ARD2} >> /Library/Logs/DSE-RenameComputer.log
else
	/bin/echo "    Setting Asset Tag to: ${ARD2}" >> /Library/Logs/DSE-RenameComputer.log
fi

/usr/bin/defaults write /Library/Preferences/com.apple.RemoteDesktop Text1 "${SN}"
/usr/bin/defaults write /Library/Preferences/com.apple.RemoteDesktop Text2 "${ARD2}"
/usr/sbin/scutil --set ComputerName "${name}"
/usr/sbin/scutil --set HostName "${name}"
/usr/sbin/scutil --set LocalHostName "${lcName}"


if [ ${org} = "SINC" ]; then
	/bin/echo "Firing off Jamf Policies: SINC - Install Root Applications and Scripts, and SINC - Install Base Applications." >> /Library/Logs/DSE-RenameComputer.log
	/usr/local/jamf/bin/jamf policy -trigger "SINC-InstallRootAppsScripts"
	/usr/local/jamf/bin/jamf policy -trigger "SINC-InstallBaseApplications"
elif [ ${org} = "CE" ]; then
	/bin/echo "Firing off Jamf Policies: STAFF - Install Root Applications and Scripts, and STAFF - Install Base Applications." >> /Library/Logs/DSE-RenameComputer.log
	/usr/local/jamf/bin/jamf policy -trigger "STAFF-InstallRootAppsScripts"
	/usr/local/jamf/bin/jamf policy -trigger "STAFF-InstallBaseApplications"	
fi

exit 0


