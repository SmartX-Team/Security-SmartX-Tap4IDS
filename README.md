# Tap4IDS

## Overview

In order to manage multiple IDSs efficiently,software-defined networking (SDN) technology can be used. With a centralized
controller (SDN controller) of SDN technology, it is possible to easily check the network status and to forward certain flows to a specific node. The suspicious flows can be forwarded to specific IDS. If the flows from the same attack are forwarded to the same IDS, it is intuitively expected to achieve better inspection of the attack. But it is required a flow grouping scheme that determines which flows should be forwarded to which IDSs is proposed for the best intrusion detection performance.

Currently, this software is only able to evaluate a single topology with static flow grouping from other piece of software. But, we believe it can be extend with minimum understanding of linux scripting.

## Preparation

* Install Dependencies and Required Software ([LXC Linux Container](https://linuxcontainers.org/), [Java 8 Oracle](http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html), [Mininet](mininet.org))
* Download Tap4IDS from [GitHub] (https://github.com/ariscahyadi/Tap4IDS)
* Extract the LXC compressed image in from folder "images" into this directory "/var/lib/lxc"
* Clone the LXC images (n1 for host, a2 for attackers, ids-a for ids) as much as required (default topology required 18 hosts, 5 attackers, and 6 idses) using the command "lxc-clone \<image> \<clone-name>"
* Extract the controller software ([ONOS] (http://onosproject.org/) for traffic controller, [OpenDaylight] (https://www.opendaylight.org/) for Tapping Controller) from folder "Software"

## Experiment (Execution)

* **exp_preparation.sh** for preparing the OVS hosts topology through mininet, starting hosts and attackers LXC containers, and start the ONOS Controller including opening the ONOS UI (through firefox)
* **tap_preparation.sh** for preparing the OVS tap, starting idses LXC container, start the OpenDaylight Controller (including opening UI with firefox), and applying the tap configuration based on the flow grouping file
* **exp_execution.sh** for generating the traffic between hosts and attacks from attackers, activate the mirroring in the several OVS, and execute the IDS alarms from captured packets in IDSes. This script will ask for inputs (name for experiment output, duration of the experiment, and number IDS to be used)
* **exp_clean.sh** for stopping all LXC containers and clear the OVS bridges configuration

## Customization and Enhancement

- Comming Soon -

Contact : aris@nm.gist.ac.kr (NetCS Laboratory, GIST)
