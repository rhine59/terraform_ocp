#!/bin/sh
rm -fr ~/.ssh/*
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
for i in `cat /etc/hosts|grep -i 'ocp'| awk '{print $3'}`
do
	ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$i
done
