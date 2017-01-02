# FUNCTION TO SETUP THE TAPPING NETWORK
#======================================

function tapping_configuration {

#TAP4
#====

sudo ovs-vsctl add-br tap4
sudo ovs-vsctl set bridge tap4 other-config:datapath-id=1111111111111114
sudo ovs-vsctl set-controller tap4 tcp:127.0.0.1:6634

sudo ovs-vsctl add-port tap4 tap4-agg1
sudo ovs-vsctl set interface tap4-agg1 type=patch
sudo ovs-vsctl set interface tap4-agg1 options:peer=agg1-tap4

sudo ovs-vsctl add-port tap4 tap4-2001
sudo ovs-vsctl set interface tap4-2001 type=patch
sudo ovs-vsctl set interface tap4-2001 options:peer=2001-tap4


#TAP5
#====

sudo ovs-vsctl add-br tap5
sudo ovs-vsctl set bridge tap5 other-config:datapath-id=1111111111111115
sudo ovs-vsctl set-controller tap5 tcp:127.0.0.1:6634

sudo ovs-vsctl add-port tap5 tap5-agg1
sudo ovs-vsctl set interface tap5-agg1 type=patch
sudo ovs-vsctl set interface tap5-agg1 options:peer=agg1-tap5

sudo ovs-vsctl add-port tap5 tap5-2002
sudo ovs-vsctl set interface tap5-2002 type=patch
sudo ovs-vsctl set interface tap5-2002 options:peer=2002-tap5


#TAP6
#====

sudo ovs-vsctl add-br tap6
sudo ovs-vsctl set bridge tap6 other-config:datapath-id=1111111111111116
sudo ovs-vsctl set-controller tap6 tcp:127.0.0.1:6634

sudo ovs-vsctl add-port tap6 tap6-agg1
sudo ovs-vsctl set interface tap6-agg1 type=patch
sudo ovs-vsctl set interface tap6-agg1 options:peer=agg1-tap6

sudo ovs-vsctl add-port tap6 tap6-2003
sudo ovs-vsctl set interface tap6-2003 type=patch
sudo ovs-vsctl set interface tap6-2003 options:peer=2003-tap6


#AGG1
#====

sudo ovs-vsctl add-br agg1
sudo ovs-vsctl set bridge agg1 other-config:datapath-id=1111111111111121
sudo ovs-vsctl set-controller agg1 tcp:127.0.0.1:6634

sudo ovs-vsctl add-port agg1 agg1-tap4
sudo ovs-vsctl set interface agg1-tap4 type=patch
sudo ovs-vsctl set interface agg1-tap4 options:peer=tap4-agg1

sudo ovs-vsctl add-port agg1 agg1-tap5
sudo ovs-vsctl set interface agg1-tap5 type=patch
sudo ovs-vsctl set interface agg1-tap5 options:peer=tap5-agg1

sudo ovs-vsctl add-port agg1 agg1-tap6
sudo ovs-vsctl set interface agg1-tap6 type=patch
sudo ovs-vsctl set interface agg1-tap6 options:peer=tap6-agg1

sudo ovs-vsctl add-port agg1 ids-1
sudo ovs-vsctl add-port agg1 ids-2
sudo ovs-vsctl add-port agg1 ids-3
sudo ovs-vsctl add-port agg1 ids-4
sudo ovs-vsctl add-port agg1 ids-5
sudo ovs-vsctl add-port agg1 ids-6
}


# MAIN SCRIPT 
#============

# Setup tapping network

echo -e "\nConfiguring Switch for Tapping..."
tapping_configuration
echo -e "\nTapping Switch Configuration are done."


# Starting ODP Controller

echo -e "\nStarting OpenDaylight for Tapping Controller"
#sudo ~/opendaylight/run.sh
gnome-terminal --tab -e "sudo /home/ubuntu/opendaylight/run.sh"

echo -e "\nWait for 60 seconds for OpenDaylight properly started"
sleep 60

#Creating a Filter in AGG1
#=========================

echo -e "\nCreating filter for Tapping in OpenDaylight Controller"

echo -e "\nRead Flow Information from flow.txt file"
while read line
do
    flow=$line
    echo $flow

    FLOW=`echo $line | awk '{print $1}'`
	TX=`echo $line | awk '{print $2}'`
	RX=`echo $line | awk '{print $3}'`
	IDS=`echo $line | awk '{print $5}'`
	IDS2=`echo $line | awk '{print $6}'`

	echo -e "Capture Traffic for Flow X from host $TX to $RX and redirect to IDS $IDS & $IDS2 \n"

	TXIP=`cat host.txt | grep -w $TX | awk '{print $2}'`
	RXIP=`cat host.txt | grep -w $RX | awk '{print $2}'`

	#echo -e $TXIP
	#echo -e $RXIP
	
	IDSPORT=$(( $IDS + 3 ))
	
	IDSPORT2=$(( $IDS2 + 6 ))

	#echo -e "IDSport $IDSPORT"

	read FILTER1 < <(echo "curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"\"installInHw\"":"\"true\"", "\"name\"":"\"IDS$IDS-IDS$IDS2-F$FLOW-$TX-$RX\"", "\"node\"": {"\"id\"":"\"11:11:11:11:11:11:11:21\"", "\"type\"":"\"OF\""}, "\"priority\"":"\"65535\"", "\"etherType\"":"\"0x800\"", "\"nwSrc\"":"\"$TXIP\"", "\"nwDst\"":"\"$RXIP\"", "\"actions\"":["\"OUTPUT=$IDSPORT,$IDSPORT2\""]}' http://127.0.0.1:8080/controller/nb/v2/flowprogrammer/default/node/OF/11:11:11:11:11:11:11:21/staticFlow/IDS$IDS-IDS$IDS2-F$FLOW-$TX-$RX")
	read FILTER2 < <(echo "curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"\"installInHw\"":"\"true\"", "\"name\"":"\"IDS$IDS-IDS$IDS2-F$FLOW-$RX-$TX\"", "\"node\"": {"\"id\"":"\"11:11:11:11:11:11:11:21\"", "\"type\"":"\"OF\""}, "\"priority\"":"\"65535\"", "\"etherType\"":"\"0x800\"", "\"nwSrc\"":"\"$RXIP\"", "\"nwDst\"":"\"$TXIP\"", "\"actions\"":["\"OUTPUT=$IDSPORT,$IDSPORT2\""]}' http://127.0.0.1:8080/controller/nb/v2/flowprogrammer/default/node/OF/11:11:11:11:11:11:11:21/staticFlow/IDS$IDS-IDS$IDS2-F$FLOW-$RX-$TX")
	eval $FILTER1
	eval $FILTER2

done < flow.txt


#Open OpenDaylight Web
#=========================

echo -e "\nCreating filter for Tapping in OpenDaylight Controller"

firefox http://127.0.0.1:8080/ &
