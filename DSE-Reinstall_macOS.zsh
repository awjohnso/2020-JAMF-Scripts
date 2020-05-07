#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2020.05.07.
# Version 1.00
# Organization: Stony Brook Univeristy/DoIT
#
# This script is to be used in a JAMF policy. Paramater 4 requires the OS vanity name:
# Catalina or Mojave.
#
# The script will then do a reinstall of the macOS on the drive, erasing the contents
# of said drive.
#
# Requirements:
#
# Requires that Install macOS Catalina.app or Install macOS Mojave.app be located on the computer
# in the Applications folder. In our case the Macintosh installer is packaged up in a DMG with
# Composer which Jamf will push out in the policy before executing this script.

	# Check to ensure the argv 4 is either Catalina or Mojave. If not exit with error.
if [[ ${4} != "Catalina" && ${4} != "Mojave" || -z ${4} ]]; then

	/bin/echo ""
	/bin/echo "Bad arguments passed to the script."
	/bin/echo "Usage:"
	/bin/echo ""
	/bin/echo "`/usr/bin/basename ${4}` Catalina"
	/bin/echo "`/usr/bin/basename ${4}` Mojave"
	/bin/echo ""
	exit 1

fi

	# If Catalina, set the path to the executable, and make sure it's there.
if [ ${4} = "Catalina" ]; then
	
		# Set the path to the executable.
	myInstall="/Applications/Install macOS Catalina.app/Contents/Resources/startosinstall"

		# If the executable is not there exit in error.
	if [ -f ${myInstall} ]; then
		/bin/echo ""
		/bin/echo "!!! ${myInstall} is not in the Applications folder. !!!"
		/bin/echo ""
		exit 1
	fi
		# Warn the user.
	/bin/echo ""
	/bin/echo "!!! Wiping the hard drive and installing Catalina macOS 10.15.x. !!!"
	/bin/echo ""

elif [ ${4} = "Mojave" ]; then

		# Set the path to the executable.
	myInstall="/Applications/Install macOS Mojave.app/Contents/Resources/startosinstall"

		# If the executable is not there exit in error.
	if [ -f ${myInstall} ]; then
		/bin/echo ""
		/bin/echo "!!! ${myInstall} is not in the Applications folder. !!!"
		/bin/echo ""
		exit 1
	fi
    
		# Warn the user.
    /bin/echo ""
	/bin/echo "!!! Wiping the hard drive and installing Mojave macOS 10.14.x. !!!"
	/bin/echo ""	

fi

		# Fire off the installation.
	${myInstall} --eraseinstall --newvolumename "Macintosh HD" --agreetolicense --nointeraction &

exit 0
