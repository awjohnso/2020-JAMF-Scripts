# Author: Andrew W. Johnson
# Date: Spring 2020.
# Version 2.50
# Organization: Stony Brook Univeristy/DoIT
#
# This script was originally written by Armin Briegel
# https://scriptingosx.com/2016/01/control-apple-remote-desktop-access-with-munki/
# Modified for our environment, and then to port it over to JAMF and ZSH.
# Adds the two possible local accounts we use access the computer through ARD and allows 
# all privileges. It then removes any other accounts from accessing this computer through
# ARD and removes all privileges.
#
# The script will also add the ard_admin group to the system and in that group it nests an
# Ad group. I'm not sure this is entirely necessary.
#
# Script is a bit clunky, still learning ZSH, and do not feel the as proficient with it, as
# say Perl.
#

	# Set the variable kickstart to the path.
kickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
admins=( $(/usr/bin/dscl . read Groups/admin GroupMembership) )
nonAdmins=( $(/usr/bin/dscl . -list /Users | /usr/bin/sed 's/_.*//g' | /usr/bin/grep -wv 'daemon\|root\|jamfservice\|nobody\|psnotify\|admin\|DesktopSupport' | /usr/bin/sed '/^$/d') )


	# Checking to see if All Users access is off.
all_users=$(/usr/bin/defaults read /Library/Preferences/com.apple.RemoteManagement ARD_AllLocalUsers 2>/dev/null)
if [[ ${all_users} -eq 1 ]]; then
	/bin/echo "All Users Access is enabled. Turning it off..."
	$kickstart -configure -allowAccessFor -specifiedUsers # Enable access for only specified users.
else
 	/bin/echo "All Users Access is not enabled."
fi

	# Adding local admins to all privileges.
for i in "${admins[@]}"; do
	if [[ ${i} = "DesktopSupport" || ${i} = "admin" ]]; then
		/bin/echo "$i is an allowed user of Remote Desktop. Enabling..."
		#echo "adding user ${i}"
		${kickstart} -configure -access -on -privs -all -users $i
	fi
done

	# Removing non specified all other users form accessing Remote Desktop
for i in "${nonAdmins[@]}"; do
	/bin/echo "${i} is not allowed access to Remote Desktop. Removing..."
	${kickstart} -configure -access -off -privs -none -users $i
done

	# Checking to see if Directory Group Logins is enabled.
dir_logins=$(/usr/bin/defaults read /Library/Preferences/com.apple.RemoteManagement DirectoryGroupLoginsEnabled 2>/dev/null)
if [[ ${dir_logins} -ne 1 ]]; then
	/bin/echo "DirectoryGroupLoginsEnabled is not enabled. Fixing..."
		# Enable directory logins.
	${kickstart} -configure -clientopts -setdirlogins -dirlogins yes
else
 	/bin/echo "DirectoryGroupLoginsEnabled is enabled."
fi

	# Checking to see if ard_admin group exists.
group=$(/usr/bin/dscl . list /Groups | /usr/bin/egrep -ic ard_admin)
if [[ ${group} -ne 1 ]]; then
	/bin/echo "Local ard_admin group does not exist. Will now create..."
		# Create a local ard_admin group using dscl
	/usr/bin/dscl . -create /Groups/ard_admin
	/usr/bin/dscl . -create /Groups/ard_admin PrimaryGroupID "530"
	/usr/bin/dscl . -create /Groups/ard_admin Password "*"
	/usr/bin/dscl . -create /Groups/ard_admin RealName "ard_admin"
	/usr/bin/dscl . -create /Groups/ard_admin GroupMembers ""
	/usr/bin/dscl . -create /Groups/ard_admin GroupMembership ""
else
 	/bin/echo "Local ard_admin group exists."
fi

	# Checking to see if the AD "TLT ARD admins" group is nested in the ard_admin local group.
isNested=$(/usr/bin/dscl . read /Groups/ard_admin NestedGroups 2>/dev/null | /usr/bin/cut -d " " -f 2 | /usr/bin/grep -ic 1AFA17DF-C645-4CAF-847A-3770B4981F6B 2>/dev/null)
if [[ ${isNested} -ne 1 ]]; then
	/bin/echo "\"TLT ARD admins\" group is not nested in ard_admin local group. Adding it now..."
	/usr/sbin/dseditgroup -o edit -a "SUNYSB.EDU\TLT ARD Admins" -t group ard_admin
else
	/bin/echo "\"TLT ARD admins\" group is nested in ard_admin local group."
fi
	# Enable ARD access for the local ard_admin group.
/usr/sbin/dseditgroup -o edit -a "SUNYSB.EDU\TLT ARD Admins" -t group ard_admin


	# Checking to see if ARD is running.
ardrunning=$(/bin/ps ax | /usr/bin/grep -c -i "[Aa]rdagent")

if [[ ${ardrunning} -eq 0 ]]; then
	/bin/echo "ARD is not running."
#	$kickstart -activate # Start it all up
else
 	/bin/echo "ARD is running."
fi

exit 0

