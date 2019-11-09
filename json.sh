#!/bin/sh
for i in `terraform output master_ip|tr -d "\""|tr -d ,|sed '/\[/d'|sed '/\]/d'`
do
	echo ip $i
done
