#!/bin/sh
# $1: ifname.
# echo "This is a script to enable the modem."


modem_enable=`nvram get modem_enable`
modem_mode=`nvram get modem_mode`
modem_roaming=`nvram get modem_roaming`
modem_roaming_mode=`nvram get modem_roaming_mode`
modem_roaming_isp=`nvram get modem_roaming_isp`
modem_roaming_imsi=`nvram get modem_roaming_imsi`
modem_autoapn=`nvram get modem_autoapn`
modem_autoapn_imsi=`nvram get modem_autoapn_imsi`
modem_type=`nvram get usb_modem_act_type`
act_node1=usb_modem_act_int
act_node2=usb_modem_act_bulk
modem_vid=`nvram get usb_modem_act_vid`
modem_pid=`nvram get usb_modem_act_pid`
modem_dev=`nvram get usb_modem_act_dev`
modem_pin=`nvram get modem_pincode`
modem_pdp=`nvram get modem_pdp`
modem_isp=`nvram get modem_isp`
modem_apn=`nvram get modem_apn`
modem_user=`nvram get modem_user`
modem_pass=`nvram get modem_pass`

at_lock="flock -x /tmp/at_cmd_lock"


# $1: ifname.
_get_wdm_by_usbnet(){
	rp1=`readlink -f /sys/class/net/$1/device 2>/dev/null`
	if [ "$rp1" == "" ]; then
		echo ""
		return
	fi

	rp2=
	i=0
	while [ $i -lt 10 ]; do
		rp2=`readlink -f /sys/class/usb/cdc-wdm$i/device 2>/dev/null`
		if [ "$rp2" == "" ]; then
			i=$((i+1))
			continue
		fi

		if [ "$rp1" == "$rp2" ]; then
			echo "/dev/cdc-wdm$i"
			return
		fi

		i=$((i+1))
	done

	echo ""
}

# $1: ifname.
_get_qcqmi_by_usbnet(){
	rp1=`readlink -f /sys/class/net/$1/device 2>/dev/null`
	if [ "$rp1" == "" ]; then
		echo ""
		return
	fi

	rp2=
	i=0
	while [ $i -lt 10 ]; do
		rp2=`readlink -f /sys/class/GobiQMI/qcqmi$i/device 2>/dev/null`
		if [ "$rp2" == "" ]; then
			i=$((i+1))
			continue
		fi

		if [ "$rp1" == "$rp2" ]; then
			echo "qcqmi$i"
			return
		fi

		i=$((i+1))
	done

	echo ""
}

_find_usb3_path(){
	all_paths=`nvram get xhci_ports`

	count=1
	for path in $all_paths; do
		len=${#path}
		target=`echo $1 |head -c $len`
		if [ "$target" == "$path" ]; then
			echo "$count"
			return
		fi

		count=$(($count+1))
	done

	echo "-1"
}

_find_usb2_path(){
	all_paths=`nvram get ehci_ports`

	count=1
	for path in $all_paths; do
		len=${#path}
		target=`echo $1 |head -c $len`
		if [ "$target" == "$path" ]; then
			echo "$count"
			return
		fi

		count=$(($count+1))
	done

	echo "-1"
}

_find_usb1_path(){
	all_paths=`nvram get ohci_ports`

	count=1
	for path in $all_paths; do
		len=${#path}
		target=`echo $1 |head -c $len`
		if [ "$target" == "$path" ]; then
			echo "$count"
			return
		fi

		count=$(($count+1))
	done

	echo "-1"
}

_find_usb_path(){
	ret=`_find_usb3_path "$1"`
	if [ "$ret" == "-1" ]; then
		ret=`_find_usb2_path "$1"`
		if [ "$ret" == "-1" ]; then
			ret=`_find_usb1_path "$1"`
		fi
	fi

	echo "$ret"
}


if [ "$modem_type" == "" ]; then
	find_modem_type.sh

	modem_type=`nvram get usb_modem_act_type`
	if [ "$modem_type" == "" ]; then
		echo "Can't get usb_modem_act_type!"
		exit 1
	fi
fi

act_node=
if [ "$modem_type" == "tty" -o "$modem_type" == "mbim" ]; then
	if [ "$modem_type" == "tty" -a "$modem_vid" == "6610" ]; then # e.q. ZTE MF637U
		act_node=$act_node1
	else
		act_node=$act_node2
	fi
else
	act_node=$act_node1
fi

modem_act_node=`nvram get $act_node`
if [ "$modem_act_node" == "" ]; then
	find_modem_node.sh

	modem_act_node=`nvram get $act_node`
	if [ "$modem_act_node" == "" ]; then
		echo "Can't get usb_modem_act_int!"
		exit 2
	fi
fi

echo "VAR: modem_enable($modem_enable) modem_autoapn($modem_autoapn) modem_act_node($modem_act_node) modem_type($modem_type) modem_vid($modem_vid) modem_pid($modem_pid) modem_pin($modem_pin) modem_apn($modem_apn) modem_isp($modem_isp)";

if [ "$modem_enable" == "0" ]; then
	echo "Don't enable the USB Modem."
	exit 0
fi

if [ "$modem_type" == "tty" -o "$modem_type" == "qmi" -o "$modem_type" == "mbim" -o "$modem_type" == "gobi" ]; then
	# Set full functionality
	nvram set usb_modem_act_reset=0
	at_ret=`$at_lock modem_at.sh '+CFUN?' |grep "+CFUN: 1" 2>/dev/null`
	if [ "$at_ret" == "" ]; then
		echo "set +CFUN=1."
		nvram set usb_modem_act_reset=1
		#at_ret=`$at_lock modem_at.sh '+CFUN=1,1' |grep "OK" 2>/dev/null`
		at_ret=`$at_lock modem_at.sh '+CFUN=1' |grep "OK" 2>/dev/null`
		if [ "$at_ret" == "OK" ]; then
			tries=1
			at_ret=""
			while [ $tries -le 30 -a "$at_ret" == "" ]; do
				echo "wait for reset...$tries"
				sleep 1

				at_ret=`$at_lock modem_at.sh '+CFUN?' |grep "+CFUN: 1" 2>/dev/null`
				tries=$((tries + 1))
			done
			nvram set usb_modem_act_reset=0

			if [ "$at_ret" == "" ]; then
				echo "Fail to reset the modem."
				exit 4
			fi
		else
			echo "Fail to set +CFUN=1."
			nvram set usb_modem_act_reset=0
			exit 5
		fi
	fi

	# input PIN if need.
	modem_status.sh sim
	modem_status.sh simauth
	ret=`nvram get usb_modem_act_sim`
	if [ "$ret" != "1" ]; then
		if [ "$ret" == "2" -a "$modem_pin" != "" ]; then
			modem_status.sh simpin "$modem_pin"
			sleep 1

			modem_status.sh sim
			modem_status.sh simauth
			ret=`nvram get usb_modem_act_sim`
		fi

		if [ "$ret" != "1" ]; then
			echo "Incorrect SIM card or can't input the correct PIN/PUK code."
			exit 3
		fi
	fi

	modem_status.sh setmode $modem_mode

	modem_status.sh imsi
	modem_status.sh imei
	modem_status.sh iccid
	modem_status.sh hwver

	# set COPS.
	# Home service.
	if [ "$modem_roaming" != "1" ]; then
		at_ret=`$at_lock modem_at.sh '+COPS?' 2>/dev/null`
		ret=`echo "$at_ret" |grep "COMMAND NOT SUPPORT"`
		if [ "$ret" == "" ]; then
			echo "Can execute +COPS..."
			ret=`echo "$at_ret" |grep "+COPS: 0,"`
			if [ "$ret" == "" ]; then
				echo "set +COPS=0."
				at_ret=`$at_lock modem_at.sh '+COPS=0' |grep "OK" 2>/dev/null`
				if [ "$at_ret" != "OK" ]; then
					echo "Fail to set +COPS=0."
					exit 6
				fi
			fi
		else
			echo "Don't support +COPS."
		fi

		if [ "$modem_type" == "gobi" ]; then
			target=""
			at_ret=`$at_lock modem_at.sh '+CGNWS' |grep "+CGNWS:" |awk '{FS=":"; print $2}' 2>/dev/null`
			if [ "$at_ret" != "" ]; then
				mcc=`echo "$at_ret" |awk '{FS=","; print $5}' 2>/dev/null`
				mnc=`echo "$at_ret" |awk '{FS=","; print $6}' 2>/dev/null`
				target=$mcc$mnc
			fi
			if [ "$modem_autoapn_imsi" != "" -a "$modem_autoapn_imsi" == "$target" ]; then
				modem_autoapn=0
			fi
		fi

		if [ "$modem_autoapn" != "" -a "$modem_autoapn" != "0" ]; then
			modem_autoapn.sh

			modem_isp=`nvram get modem_isp`
			modem_apn=`nvram get modem_apn`
			modem_user=`nvram get modem_user`
			modem_pass=`nvram get modem_pass`
		fi
	elif [ "$modem_roaming_mode" == "1" ]; then
		# roaming manually...
		echo "roaming manually..."
		modem_status.sh station "$modem_roaming_isp"
		modem_autoapn.sh set $modem_roaming_imsi

		modem_isp=`nvram get modem_isp`
		modem_apn=`nvram get modem_apn`
		modem_user=`nvram get modem_user`
		modem_pass=`nvram get modem_pass`
	else
		# roaming automatically...
		echo "roaming automatically..."
	fi

	at_ret=`$at_lock modem_at.sh '+CGATT?' 2>/dev/null`
	ret=`echo "$at_ret" |grep "COMMAND NOT SUPPORT"`
	if [ "$ret" == "" ]; then
		echo "Can execute +CGATT..."
		tries=1
		at_ret=`echo "$at_ret" |grep "+CGATT: 1"`
		while [ $tries -le 30 -a "$at_ret" == "" ]; do
			echo "wait for network registered...$tries"
			sleep 1

			at_ret=`$at_lock modem_at.sh '+CGATT?' |grep "+CGATT: 1" 2>/dev/null`
			tries=$((tries + 1))
		done

		if [ "$at_ret" == "" ]; then
			echo "Fail to register network, please check."
			exit 7
		else
			echo "Successfull to register network."
		fi
	else
		echo "Don't support +CGATT."
	fi
fi

if [ "$modem_vid" == "8193" ];then
	# just for D-Link DWM-156 A7.
	#at_ret=`$at_lock modem_at.sh '+BMHPLMN' |grep "+BMHPLMN: " 2>/dev/null`
	#if [ "$at_ret" != "" ]; then
	#	plmn=`echo $at_ret | awk '{print $2}'`
	#	echo "IMSI: $plmn."
	#fi

	# put the dongle in the general procedure.
	exit 0

	at_ret=`$at_lock modem_at.sh '+CFUN=1' |grep "OK" 2>/dev/null`
	if [ "$at_ret" != "OK" ]; then
		echo "Fail to set CFUN=1."
		exit -1
	fi

	tries=1
	at_ret=""
	while [ $tries -le 30 -a "$at_ret" == "" ]; do
		echo "wait for network registered...$tries"
		sleep 1

		at_ret=`$at_lock modem_at.sh '+CGATT?' |grep "+CGATT: 1" 2>/dev/null`
		tries=$((tries + 1))
	done

	if [ "$at_ret" == "" ]; then
		echo "Fail to register network, please check."
		exit -1
	fi

	echo "Successfull to register network."
elif [ "$modem_type" == "qmi" ]; then
	if [ "$modem_dev" == "" ]; then
		path=`_find_usb_path "$modem_act_path"`
		modem_dev=`nvram get usb_path"$path"_act`
		if [ "$modem_dev" == "" ]; then
			echo "Couldn't get the QMI dev..."
			exit 8
		fi

		nvram set usb_modem_act_dev=$modem_dev
		echo "Got the QMI dev: $modem_dev."
	fi

	wdm=`_get_wdm_by_usbnet $modem_dev`

	if [ "$modem_user" != "" -o "$modem_pass" != "" ]; then
		flag_auth="--auth-type both"
		if [ "$modem_user" != "" ]; then
			flag_auth="$flag_auth --username $modem_user"
		fi
		if [ "$modem_pass" != "" ]; then
			flag_auth="$flag_auth --password $modem_pass"
		fi
	else
		flag_auth=""
	fi

	echo "QMI($wdm): try if the network is registered..."
	at_ret=`uqmi -d $wdm --keep-client-id wds --start-network $modem_apn $flag_auth |grep "handle=" 2>>/tmp/usb.log`
	if [ "$at_ret" != "" ]; then
		echo "QMI: Successfull to register network."
	elif [ "$modem_vid" == "4817" -a "$modem_pid" == "5132" ]; then
		# put the dongle in the general procedure.
		exit 0

		echo "Restarting the MT and set it as online mode..."
		nvram set usb_modem_reset_huawei=1
		at_ret=`$at_lock modem_at.sh '+CFUN=1,1'`

		tries=1
		at_ret=""
		while [ $tries -le 30 -a "$at_ret" == "" ]; do
			echo "wait the modem to wake up...$tries"
			sleep 1

			at_ret=`$at_lock modem_at.sh '+CGATT?' |grep "+CGATT: 1" 2>/dev/null`
			tries=$((tries + 1))
		done

		if [ "$ret" == "" ]; then
			echo "Fail to reset the modem, please check."
			exit -1
		fi

		echo "Successfull to reset the modem."
		nvram unset usb_modem_reset_huawei
	fi

	tries=1
	at_ret=""
	while [ $tries -le 15 -a "$at_ret" == "" ]; do
		echo "QMI: wait for network connecting...$tries"
		sleep 1

		at_ret=`uqmi -d $wdm --get-data-status |grep "=connected" 2>/dev/null`
		tries=$((tries + 1))
	done

	if [ "$at_ret" == "" ]; then
		echo "Fail to register network, please check."
		exit 9
	fi

	echo "QMI: Successfull to connect network."
elif [ "$modem_type" == "gobi" ]; then
	qcqmi=`_get_qcqmi_by_usbnet $modem_dev`
	echo "Got qcqmi: $qcqmi."

	cmd_pipe="/tmp/pipe"

	gobi_pid=`pidof gobi`
	if [ "$gobi_pid" != "" ]; then
		# WDS stop the data session
		echo "4" >> $cmd_pipe
		sleep 1

		# disconnect to GobiNet.
		echo "2" >> $cmd_pipe
		sleep 1

		killall gobi
		sleep 1
	fi

	gobi d &
	sleep 1

	# connect to GobiNet.
	echo "1,$qcqmi," >> $cmd_pipe
	sleep 1

	# set the default profile to auto-connect.
	modem_isp=`echo $modem_isp |cut -c 1-15`
	echo "5,$modem_pdp,$modem_isp,$modem_apn,$modem_user,$modem_pass," >> $cmd_pipe
	sleep 1

	# WDS set the autoconnect & roaming
	# autoconnect: 0, disable; 1, enable; 2, pause.
	# roaming: 0, allow; 1, disable. Only be activated when autoconnect is enabled.
	if [ "$modem_roaming" != "1" ]; then
		echo "7,1,1," >> $cmd_pipe
	else
		echo "7,1,0," >> $cmd_pipe
	fi
	sleep 1

	# WDS start the data session
	#echo "3" >> $cmd_pipe
	#sleep 3

	modem_status.sh rate
	modem_status.sh band

	echo "Gobi: Successfull to start network."
fi

