resource "null_resource" "generate_hosts_file" {
  depends_on = ["vsphere_virtual_machine.bastion", "vsphere_virtual_machine.master", "vsphere_virtual_machine.node", "vsphere_virtual_machine.infra"]
  provisioner "local-exec" {
    command =  "echo \"# Hosts file for Terraform generated VMs\" > /tmp/hosts"
  }
  provisioner "local-exec" {
    command =  "echo 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command =  "echo 10.134.214.138  utility >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command = "echo '${join("\n", formatlist("%s %s.%s.nip.io %s", vsphere_virtual_machine.bastion.*.default_ip_address, vsphere_virtual_machine.bastion.*.name, vsphere_virtual_machine.bastion.*.default_ip_address, vsphere_virtual_machine.bastion.*.name))}' >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command = "echo '${join("\n", formatlist("%s %s.%s.nip.io %s", vsphere_virtual_machine.master.*.default_ip_address, vsphere_virtual_machine.master.*.name, vsphere_virtual_machine.master.*.default_ip_address, vsphere_virtual_machine.master.*.name))}' >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command = "echo '${join("\n", formatlist("%s %s.%s.nip.io %s", vsphere_virtual_machine.node.*.default_ip_address, vsphere_virtual_machine.node.*.name, vsphere_virtual_machine.node.*.default_ip_address, vsphere_virtual_machine.node.*.name))}' >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command = "echo '${join("\n", formatlist("%s %s.%s.nip.io %s", vsphere_virtual_machine.infra.*.default_ip_address, vsphere_virtual_machine.infra.*.name, vsphere_virtual_machine.infra.*.default_ip_address, vsphere_virtual_machine.infra.*.name))}' >> /tmp/hosts"
  }
  provisioner "local-exec" {
    command =<<EOF
echo \#!/bin/sh > /tmp/keys.sh
echo exit 0 >> /tmp/keys.sh
echo ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N \"\" >> /tmp/keys.sh
echo for i in `cat /etc/hosts|awk '{print $3'}` >> /tmp/keys.sh
echo do >> /tmp/keys.sh
echo sshpass -p \"Passw0rd=\" ssh-copy-id -i ~/.ssh/id_rsa.pub root@\$i >> /tmp/keys.sh
echo done >> /tmp/keys.sh
chmod 755 /tmp/keys.sh
/tmp/keys.sh
EOF
  }
}

