resource "vsphere_virtual_machine" "bastion" {
  connection {
    type = "ssh"
    user = "root"
    password = "Passw0rd="
    host = "${cidrhost(var.cluster_network, var.bastion_ip_start + count.index)}"  
  }
  count            = "${var.bastion_count}"
  name 		   = "${var.cluster_prefix}bastion${format("%01d",  count.index + 1)}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder_name
  num_cpus         = 2
  memory	   = var.bastion_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size	     = 16
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  disk {
    label            = "disk1"
    size	     = var.bastion_disk1
    unit_number      = 1
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
  	host_name = "${var.cluster_prefix}bastion${format("%01d",  count.index + 1)}"
        domain    = var.virtual_machine_domain
      }
      network_interface {
	ipv4_address = "${cidrhost(var.cluster_network, var.bastion_ip_start + count.index)}"  
        ipv4_netmask = var.virtual_machine_netmask
      }

      ipv4_gateway    = var.virtual_machine_gateway
      dns_suffix_list = [var.virtual_machine_domain]
      dns_server_list = var.virtual_machine_dns_servers
    }
  }
  provisioner "file" {
    content = <<EOF
#!/bin/bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"Bastion starting!"}' https://hooks.slack.com/services/${var.slack_channel} >/dev/null 2>&1
# Extend the root logical volume with all that is allocated to disk1
partprobe ${var.disk1-name}
pvcreate ${var.disk1-name}
vg=`vgs --noheadings|awk '{print $1}'`
vgextend $vg ${var.disk1-name}
lvpath=`lvs --noheadings -o lv_name,lv_path|grep -iv swap|awk '{print $2}'`
lvresize -l +100%FREE $lvpath
xfs_growfs $lvpath

echo "*INFO* Setup networking"
myip=`hostname -I|awk '{print $1}'`
myhost=`hostname|awk '{print $1}'`
hostnamectl set-hostname $myhost.$myip.nip.io
rm -fr /etc/sysconfig/network-scripts/route-ens*
echo ADDRESS0=${var.address0} > /etc/sysconfig/network-scripts/route-ens192
echo NETMASK0=${var.netmask0} >> /etc/sysconfig/network-scripts/route-ens192
echo TYPE=Ethernet >> /etc/sysconfig/network-scripts/route-ens192
echo GATEWAY0=${var.gateway0} >> /etc/sysconfig/network-scripts/route-ens192
systemctl restart network

echo "*INFO* Registering machine with RHN"
subscription-manager unregister
subscription-manager register --username coc_europa --password Passw0rd= --auto-attach --force
subscription-manager refresh
subscription-manager attach --pool=8a85f9996c535260016c535f83b001e6
subscription-manager repos --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms" \
    --enable=rh-gluster-3-client-for-rhel-7-server-rpms

echo "*INFO* Installing required software"
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct nfs-common
yum -y install docker openshift-ansible
yum -y install atomic-openshift-clients
yum -y install glusterfs glusterfs-client-xlators glusterfs-libs glusterfs-fuse heketi-client nfs-utils sshpass
yum clean all

systemctl restart docker

echo "*INFO* See https://docs.openshift.com/container-platform/3.11/install/example_inventories.html#single-master-multi-node-ai

exit 0

EOF
    destination = "/tmp/setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh; bash /tmp/setup.sh 2>&1 | tee /tmp/setup.log",
    ]
  }  
}

