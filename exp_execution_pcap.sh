function send_traffic {

echo "Read Flow Information from flow.txt file"
while read line
do
    flow=$line
    echo $flow

    X=`echo $line | awk '{print $1}'`
	TX=`echo $line | awk '{print $2}'`
	RX=`echo $line | awk '{print $3}'`
	RATE=`echo $line | awk '{print $4}'`

	if [[ ${TX:0:1} == "n" ]] ; then
		#echo "host";
		RXIP=`cat host.txt | grep -w $RX | awk '{print $2}'`;
		echo -e "Send Traffic for Flow $X from host $TX to $RX with rate $RATE (Mbps) \n";
		#sudo lxc-attach -n $TX -- nohup iperf -c $RXIP -u -b $RATE"m" >/dev/null 2>&1 &
		sudo lxc-attach -n $RX -- nohup iperf -s -u >/dev/null 2>&1 &
		sudo lxc-attach -n $TX -- nohup /iperf2.sh $RXIP $RATE >/dev/null 2>&1 &
	else
		#echo "attacker";
		echo -e "Send Attack for Flow $X from host $TX to $RX with rate $RATE (Mbps) \n";
		#sudo lxc-attach -n $TX -- nohup ./attack.sh >/dev/null 2>&1 &
	fi

done < flow.txt

}

function stop_traffic {

echo "Read Flow Information from flow.txt file"
while read line
do
    flow=$line
    
    X=`echo $line | awk '{print $1}'`
	TX=`echo $line | awk '{print $2}'`

	if [[ ${TX:0:1} == "n" ]] ; then
		echo -e "Stop Traffic for Flow $X .... \n";
		sudo lxc-attach -n $TX -- pkill -f "iperf"

	else
		echo -e "Stop Attack for Flow $X .... \n";
		#sudo lxc-attach -n $TX -- pkill -f "nmap"
	fi

done < flow.txt

}

#STARTING THE MIRROR
#===================

function start_tx_rx_mirror {

#2001
#====

sudo ovs-vsctl add-port 2001 2001-tap4
sudo ovs-vsctl set interface 2001-tap4 type=patch
sudo ovs-vsctl set interface 2001-tap4 options:peer=tap4-2001

sudo ovs-vsctl -- set Bridge 2001 mirror=@m -- --id=@2001-tap4 get Port 2001-tap4 -- --id=@m create Mirror name=mirror4 select-all=true output-port=@2001-tap4


#2002
#====

sudo ovs-vsctl add-port 2002 2002-tap5
sudo ovs-vsctl set interface 2002-tap5 type=patch
sudo ovs-vsctl set interface 2002-tap5 options:peer=tap5-2002

sudo ovs-vsctl -- set Bridge 2002 mirror=@m -- --id=@2002-tap5 get Port 2002-tap5 -- --id=@m create Mirror name=mirror5 select-all=true output-port=@2002-tap5

#2003
#====

sudo ovs-vsctl add-port 2003 2003-tap6
sudo ovs-vsctl set interface 2003-tap6 type=patch
sudo ovs-vsctl set interface 2003-tap6 options:peer=tap6-2003

sudo ovs-vsctl -- set Bridge 2003 mirror=@m -- --id=@2003-tap6 get Port 2003-tap6 -- --id=@m create Mirror name=mirror6 select-all=true output-port=@2003-tap6

}

function start_tx_mirror {

#2001
#====

sudo ovs-vsctl add-port 2001 2001-tap4
sudo ovs-vsctl set interface 2001-tap4 type=patch
sudo ovs-vsctl set interface 2001-tap4 options:peer=tap4-2001

sudo ovs-vsctl -- set Bridge 2001 mirror=@m -- --id=@2001-eth1 get Port 2001-eth1 -- --id=@2001-eth2 get Port 2001-eth2 -- --id=@2001-eth3 get Port 2001-eth3 -- --id=@2001-eth4 get Port 2001-eth4 -- --id=@2001-eth5 get Port 2001-eth5 -- --id=@2001-tap4 get Port 2001-tap4 -- --id=@m create Mirror name=mirror4 select-src-port=[@2001-eth1,@2001-eth2,@2001-eth3,@2001-eth4,@2001-eth5] output-port=@2001-tap4


#2002
#====

sudo ovs-vsctl add-port 2002 2002-tap5
sudo ovs-vsctl set interface 2002-tap5 type=patch
sudo ovs-vsctl set interface 2002-tap5 options:peer=tap5-2002

sudo ovs-vsctl -- set Bridge 2002 mirror=@m -- --id=@2002-eth1 get Port 2002-eth1 -- --id=@2002-eth2 get Port 2002-eth2 -- --id=@2002-eth3 get Port 2002-eth3 -- --id=@2002-eth4 get Port 2002-eth4 -- --id=@2002-eth5 get Port 2002-eth5 -- --id=@2002-tap5 get Port 2002-tap5 -- --id=@m create Mirror name=mirror5 select-src-port=[@2002-eth1,@2002-eth2,@2002-eth3,@2002-eth4,@2002-eth5] output-port=@2002-tap5

#2003
#====

sudo ovs-vsctl add-port 2003 2003-tap6
sudo ovs-vsctl set interface 2003-tap6 type=patch
sudo ovs-vsctl set interface 2003-tap6 options:peer=tap6-2003

sudo ovs-vsctl -- set Bridge 2003 mirror=@m -- --id=@2003-eth1 get Port 2003-eth1 -- --id=@2003-eth2 get Port 2003-eth2 -- --id=@2003-eth3 get Port 2003-eth3 -- --id=@2003-eth4 get Port 2003-eth4 -- --id=@2003-eth5 get Port 2003-eth5 -- --id=@2003-tap6 get Port 2003-tap6 -- --id=@m create Mirror name=mirror6 select-src-port=[@2003-eth1,@2003-eth2,@2003-eth3,@2003-eth4,@2003-eth5] output-port=@2003-tap6

}

function stop_mirror {

sudo ovs-vsctl clear bridge 2001 mirrors
sudo ovs-vsctl del-port 2001 2001-tap4

sudo ovs-vsctl clear bridge 2002 mirrors
sudo ovs-vsctl del-port 2002 2002-tap5

sudo ovs-vsctl clear bridge 2003 mirrors
sudo ovs-vsctl del-port 2003 2003-tap6

}

# MAIN EXECUTION
#=================

# Asking input parameters

echo -n "Please input the number of IDS for this experiment: "
read IDSNUMBER
echo -n "Please assign filename for output of this experiment: "
read FILENAME
echo -n "Please specify duration (seconds) of this experiment: "
read TIME

# Start to Send the traffic

#/home/aris/SDN-Security/lxc_attach.sh

echo -e "Starting to send traffic between nodes....\n"

send_traffic
sleep 10
# Calling function to mirroring

start_tx_mirror

# Start capturing in IDS based on the input number

for (( i=1; i <= IDSNUMBER ; i++ ))
do
	echo -e "Capturing packet on IDS $i with filename ids-$i-$FILENAME.pcap"
	gnome-terminal --title="IDS-$i Terminal" -e "sudo lxc-attach -n ids-$i -- tcpdump -i eth0 -w ids-$i-$FILENAME.pcap" 
done

# Waiting for specific duration

sleep $TIME

# Stop capturing

for (( i=1; i <= IDSNUMBER ; i++ ))
do
	echo -e "Stop Capture packet on IDS $i... \n"
	sudo lxc-attach -n ids-$i -- pkill -f "tcpdump"
done

# Stop mirroring

echo -e "Stop Mirroring in the switch...\n"

stop_mirror

# Stop Send traffic

echo -e "Stop Send Traffic and Attack...\n"

stop_traffic

# Generating alarms from Pcap File 


for (( i=1; i <= IDSNUMBER ; i++ ))
do
	echo -e "Processing IDS $i ... "
	gnome-terminal --title="IDS-$i Terminal" -e "sudo lxc-attach -n ids-$i -- snort -c /etc/snort/snort.conf -l /home/ubuntu/ -r /home/ubuntu/ids-$i-$FILENAME.pcap -A fast -C"
done

