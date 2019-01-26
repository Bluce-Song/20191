#!/bin/sh
#path

upd=/mnt/nfs/build-aip-update/aip-update
aip=/mnt/nfs/aip
cur=/mnt
usb=/mnt/usb1/aip
net=/mnt/network

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

LD_LIBRARY_PATH=/lib:usr/lib:/opt/qt-4.8/lib $LD_LIBRARY_PATH

export LD_LIBRARY_PATH

export set QTDIR=/opt/qt-4.8
export set QPEDIR=/opt/qt-4.8
export set QWS_DISPLAY="LinuxFB:/dev/fb0"
export set QWS_DISPLAY="LinuxFB:mmWidth236:mmHeight173:0"
export set QWS_KEYBOARD="TTY:/dev/tty1"

export set TSLIB_TSDEVICE=/dev/input/event0
export set TSLIB_CALIBFILE=/etc/pointercal
export set TSLIB_CONFFILE=/etc/ts.conf
export set TSLIB_PLUGINDIR=/lib/ts
export set QWS_MOUSE_PROTO='TSLIB:/dev/input/event0'
	
export set QT_PLUGIN_PATH=$QTDIR/plugins/
export set QT_QWS_FONTDIR=$QTDIR/lib/fonts/
export set PATH=$QPEDIR/bin:$PATH
export set LD_LIBRARY_PATH=$QTDIR/lib:$QPEDIR/plugins/imageformats:$LD_LIBRARY_PATH

export ODBCINI=/usr/local/arm/unixODBC/etc/odbc.ini                             
export ODBCSYSINI=/usr/local/arm/unixODBC/etc/

cd /mnt/

insmod /lib/modules/rt3070sta.ko
ifconfig ra0 up
wpa_supplicant -B -D wext -i ra0 -c /etc/wpa_supplicant.conf 
udhcpc -i ra0&

ifconfig can0 down
ip link set can0 type can bitrate 500000
ifconfig can0 up

./net -qws&

#copy client program from nfs file
if [ -f $aip ]; then
	echo "copy aip from nfs file"
	rm ${cur}/aip*
    cp $aip $cur 
else
    echo "aip-client not found in nfs file"    
fi

#copy client program from network or usbdisk
file=$(ls $net | grep aip)
if [ -n "$file" ]; then
	echo "copy aip-client from network"
	rm ${cur}/aip*
	mv ${net}/aip* $cur
	chmod +x ${cur}/aip*
elif [ -d $usb ]; then
	file=$(ls $usb | grep aip)
	if [ -n "$file" ]; then
		echo "copy aip from usbdisk"
		rm ${cur}/aip*
		cp ${usb}/aip* $cur
	fi
        
else
	echo "network file is empty"
	echo "usbdisk file is empty"
fi

file=$(ls $net | grep .bin)
if [ -n "$file" ]; then
     echo "network update is empty"
     /mnt/update -qws
elif [ -d $usb ]; then
     echo "usbdisk update is empty"
     file=$(ls $usb | grep .bin)
     if [ -n "$file" ]; then
     /mnt/update -qws
     fi
fi

rm ${net}/*.bin

#find new client
for c in $(ls $cur | grep aip)
do
	echo $c
	chmod +x ${cur}/$c
done

#startup client
if [ -n "$c" ]; then
	chmod +x ${cur}/$c
	${cur}/$c -qws&
	${cur}/wdog -qws&
else
	echo "client not found"
fi


