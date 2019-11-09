#!/bin/bash -x
echo "*INFO* Adding utility machine to hosts file
echo 10.134.214.138  utility >> /etc/hosts

echo "*INFO* Registering machine with RHN
subscription-manager unregister
subscription-manager register --username coc_europa --password Passw0rd= --auto-attach --force
subscription-manager refresh
subscription-manager attach --pool=8a85f9996c535260016c535f83b001e6
subscription-manager repos --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms"

echo "*INFO* Installing required software
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct 
yum -y install cri-o openshift-ansible

echo "*INFO* Generating a copying SSH keys
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
sshpass -p "Passw0rd=" ssh-copy-id -i ~/.ssh/id_rsa.pub root@localhost

echo "*INFO* See https://docs.openshift.com/container-platform/3.11/install/example_inventories.html#single-master-multi-node-ai

echo "*INFO* execution of /tmp/setup.sh complete"
exit 0
