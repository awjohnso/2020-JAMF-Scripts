#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2020.05.05.
# Version 1.00
# Organization: Stony Brook Univeristy/DoIT
#
# This script was ported over from Munki into Jamf to add printers to our lab computers.
# The script takes 5 paramaters:
# #4: the printer GUI Name.
# #5: the printer queue.
# #6: the full path to the printer driver.
# #7: if the printer should be set as default ( Y / N ). This doesn't seem to work...
# #8: the printer model.
#
# If the printer already exists, the script will exit. If the printer driver is missing it will error out.


    # Setup the printer paramaters.

printerGUIname=${4}
printerQueue=${5}
printerDriver=${6}
printerDefault=${7}
printerModel=${8}
printerAddress="popup://elmo.campus.stonybrook.edu:515"
printerOption1="XRXOptionDuplex=True"

    # If the printer driver does not exist, do not install the printer and throw an error.
if [ ! -f "${printerDriver}" ]; then
	/bin/echo ""
	/bin/echo "Print driver:"
	/bin/echo "${printerDriver}"
	/bin/echo "is not installed."
	/bin/echo "Please install the print drivers for printer:"
	/bin/echo "${printerModel}."
	/bin/echo ""
	exit 1
else
	/bin/echo "Printer driver ${printerDriver} is installed on the system. Moving on..."
fi

	# Check to see if the printer is actually installed.
isThere=$( /usr/bin/lpstat -v 2>/dev/null | /usr/bin/egrep -ic ${printerQueue} )

if [ ${isThere} -eq 0 ]; then

		# Add the printer.
	/bin/echo "Adding printer: ${printerGUIname}"
	/usr/sbin/lpadmin -D ${printerGUIname} -p ${printerGUIname} -v ${printerAddress}/${printerQueue} -P "${printerDriver}" -o ${printerOption1} -o printer-is-shared=false -E

		# Set the printer as default should it be required. Doesn't seem to work... but doing it anyway.
	if [ $printerDefault = "Y" ]; then
		/bin/echo "Setting ${printerQueue} as default."
		/usr/bin/lpoptions -d ${printerQueue} > /dev/null 2>&1
	else
    	/bin/echo "Not setting ${printerQueue} as default."
    fi
		# Enable and start the printers on the system (after adding the printer initially it is paused).
	/bin/echo "Enabling ${printerQueue}."
	/usr/sbin/cupsenable $( /usr/bin/lpstat -p | /usr/bin/grep -w "printer" | /usr/bin/awk '{print $2}' )
else
	    # Nothing to do.
	/bin/echo "Printer has already been added."
fi

exit 0

