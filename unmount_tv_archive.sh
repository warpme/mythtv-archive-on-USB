#!/bin/sh

/usr/bin/perl /usr/local/bin/osd_notify.pl " " "prepare-to-unmount" "tvarchive"

echo "Checking is any archive volume mounted..."
mounted=`mount -v | grep "/myth/tv-archive" | sed -e "s/\(.*\)\s*on\(.*\)\s*type\(.*\)/\2/" | sed -e "s/\/myth\/tv-archive\///g"`
if [ -z $mounted ]; then
  /usr/bin/perl /usr/local/bin/osd_notify.pl " " "no-disk-detected" "tvarchive"
  echo "No any archive volumes found. Exiting."
  exit 1 
fi

echo "Launching run-tv-archive.sh with disconnected \"$mounted\""
/usr/local/bin/run-tv-archive.sh $mounted disconnected >> /var/log/ext-usb-tvarchive.log

exit 0
