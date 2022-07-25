#!/bin/sh

connected_archives=`ls -1 /var/lib/run-tv-archive/*.connected 2>/dev/null | sed -e "s|\.connected||g" -e "s|/var/lib/run-tv-archive/||"`
echo "Connected archives:"${connected_archives}

if [ ! x${connected_archives} = "x" ] ; then

    for archive in ${connected_archives} ; do

        /usr/bin/perl /usr/local/bin/osd_notify.pl "${archive}" "prepare-to-unmount" "tvarchive"

        echo "Launching run-tv-archive.sh with command disconnected for ${archive} tvarchive ..."
        /usr/local/bin/run-tv-archive.sh ${archive} disconnected >> /var/log/ext-usb-tvarchive.log

        umount /media/${archive}

    done

else

    echo " "
    echo "It seems there is no any tvachive connected ..."
    echo " "
    /usr/bin/perl /usr/local/bin/osd_notify.pl " " "no-disk-detected" "tvarchive"

fi

exit 0
