for i in `cat /etc/hosts|grep -iv util|awk '{print $1}'|grep -v ::|grep -v 127|grep -iv bastion|grep -iv util`; 
do 
	scp hosts root@$i:/etc/hosts
done

