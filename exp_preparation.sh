function lxc_start {

sudo lxc-start -n n1 -d
sudo lxc-start -n n2 -d
sudo lxc-start -n n3 -d
sudo lxc-start -n n4 -d
sudo lxc-start -n n5 -d
sudo lxc-start -n n6 -d
sudo lxc-start -n n7 -d
sudo lxc-start -n n8 -d
sudo lxc-start -n n9 -d
sudo lxc-start -n n10 -d
sudo lxc-start -n n11 -d
sudo lxc-start -n n12 -d
sudo lxc-start -n n13 -d
sudo lxc-start -n n14 -d
sudo lxc-start -n n15 -d
sudo lxc-start -n n16 -d
sudo lxc-start -n n17 -d
sudo lxc-start -n n18 -d

sudo lxc-start -n a1 -d
sudo lxc-start -n a2 -d
sudo lxc-start -n a3 -d
sudo lxc-start -n a4 -d
sudo lxc-start -n a5 -d

sudo lxc-start -n ids-1 -d
sudo lxc-start -n ids-2 -d
sudo lxc-start -n ids-3 -d
sudo lxc-start -n ids-4 -d
sudo lxc-start -n ids-5 -d
sudo lxc-start -n ids-6 -d
}

function add_port {

sudo ovs-vsctl add-port 3001 n1
sudo ovs-vsctl add-port 3001 n2
sudo ovs-vsctl add-port 3002 n3
sudo ovs-vsctl add-port 3002 n4
sudo ovs-vsctl add-port 3003 n5
sudo ovs-vsctl add-port 3003 n6
sudo ovs-vsctl add-port 3004 n7
sudo ovs-vsctl add-port 3004 n8
sudo ovs-vsctl add-port 3005 n9
sudo ovs-vsctl add-port 3005 n10
sudo ovs-vsctl add-port 3006 n11
sudo ovs-vsctl add-port 3006 n12
sudo ovs-vsctl add-port 3007 n13
sudo ovs-vsctl add-port 3007 n14
sudo ovs-vsctl add-port 3008 n15
sudo ovs-vsctl add-port 3008 n16
sudo ovs-vsctl add-port 3009 n17
sudo ovs-vsctl add-port 3009 n18

sudo ovs-vsctl add-port 3001 a1
sudo ovs-vsctl add-port 3003 a2
sudo ovs-vsctl add-port 3004 a3
sudo ovs-vsctl add-port 3006 a4
sudo ovs-vsctl add-port 3007 a5

}

function start_ping {
sudo lxc-attach -n n1 -- nohup ping -c 10 172.16.1.101  >/dev/null 2>&1 &
sudo lxc-attach -n n2 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n3 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n4 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n5 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n6 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n7 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n8 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n9 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n10 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n11 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n12 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n13 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n14 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n15 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n16 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n17 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
sudo lxc-attach -n n18 -- nohup ping -c 10 172.16.1.1  >/dev/null 2>&1 &
}

# Starting OVS and Opening Logs

sudo service openvswitch-switch start
gnome-terminal -e "tail -f /var/log/openvswitch/ovs-vswitchd.log"

# Starting ONOS Controller

echo -e "\n Starting ONOS Controller"
echo -e "\n It will open another terminal"
gnome-terminal -e "/home/ubuntu/onos-1.3.0/bin/onos-service start"

# Starting Mininet Topology

sleep 10
gnome-terminal -e "sudo python /home/ubuntu/Fat_Tree_Topology.py"

# Starting Container Node + Attacker + IDS

#gnome-terminal --tab -e "sudo ~/SDN-Security/lxc_start.sh"

echo -e "\n Starting Containers...."
lxc_start

# Starting Container Node + Attacker + IDS

echo -e "\n Add Containers's ports into OVS bridges...."
add_port

# Open the browser for ONOS Controler

sleep 10
firefox http://127.0.0.1:8181/onos/ui/index.html &

start_ping 
