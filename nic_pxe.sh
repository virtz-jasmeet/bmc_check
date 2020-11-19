#!/bin/bash

ipmiip=`ipmitool lan print | grep -i "IP Address" | grep -iv source | awk -F": " {'print $2'}`

sshpass -p ADMIN ssh -qo StrictHostKeyChecking=no admin@$ipmiip "racadm get nic.nicconfig" > /tmp/nic
for j in `cat /tmp/nic | awk {'print $1'}`
do
        echo -e "\e[94m""=========================""\e[39m" $j "\e[94m""=========================""\e[39m"
        echo
		sshpass -p ADMIN ssh -qo StrictHostKeyChecking=no admin@$ipmiip "racadm get $j"
        echo
done

rm -f /tmp/nic
