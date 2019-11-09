resource "vsphere_virtual_machine" "node" {
  connection {
    type = "ssh"
    user = "root"
    password = "Passw0rd="
    host = "${cidrhost(var.cluster_network, var.node_ip_start + count.index)}"  
  }
  count            = "${var.node_count}"
  name 		   = "${var.cluster_prefix}node${format("%01d",  count.index + 1)}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder_name
  num_cpus         = 2
  memory	   = var.node_memory
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
    size	     = var.node_disk1
    unit_number      = 1
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  disk {
    label            = "disk2"
    size	     = var.node_disk2
    unit_number      = 2
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  disk {
    label            = "disk3"
    size	     = var.node_disk3
    unit_number      = 3
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
  	host_name = "${var.cluster_prefix}node${format("%01d",  count.index + 1)}"
        domain    = var.virtual_machine_domain
      }
      network_interface {
	ipv4_address = "${cidrhost(var.cluster_network, var.node_ip_start + count.index)}"  
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
curl -X POST -H 'Content-type: application/json' --data '{"text":"Node Starting!"}' https://hooks.slack.com/services/${var.slack_channel} >/dev/null 2>&1
# Extend the root logical volume with all that is allocated to disk1
partprobe ${var.disk1-name}
pvcreate ${var.disk1-name}
vg=`vgs --noheadings|awk '{print $1}'`
vgextend $vg ${var.disk1-name}
lvpath=`lvs --noheadings -o lv_name,lv_path|grep -iv swap|awk '{print $2}'`
lvresize -l +100%FREE $lvpath
xfs_growfs $lvpath

# Create a new logical volume with all that is allocated to disk2
partprobe ${var.disk2-name}
pvcreate ${var.disk2-name}
vgcreate vg2 ${var.disk2-name}
lvcreate -n lv2 -l 100%FREE vg2
mkfs.xfs /dev/vg2/lv2
uuid=`blkid /dev/vg2/lv2|awk '{print $2}'|sed 's/\"//g'`
mkdir /home/disk2
echo "$uuid /home/disk2 xfs defaults 0 0" >> /etc/fstab
mount -a

# Create a new logical volume with all that is allocated to disk3
partprobe ${var.disk3-name}
pvcreate ${var.disk3-name}
vgcreate vg3 ${var.disk3-name}
lvcreate -n lv3 -l 100%FREE vg3
mkfs.xfs /dev/vg3/lv3
uuid=`blkid /dev/vg3/lv3|awk '{print $2}'|sed 's/\"//g'`
mkdir /home/disk3
echo "$uuid /home/disk3 xfs defaults 0 0" >> /etc/fstab
mount -a

echo "*INFO* Setup networking"
myip=`hostname -I|awk '{print $1}'`
myhost=`hostname|awk '{print $1}'`
hostnamectl set-hostname $myhost.$myip.nip.io
echo ADDRESS0=${var.address0} > /etc/sysconfig/network-scripts/route-ens192
echo NETMASK0=${var.netmask0} >> /etc/sysconfig/network-scripts/route-ens192
echo TYPE=Ethernet >> /etc/sysconfig/network-scripts/route-ens192
echo GATEWAY0=${var.gateway0} >> /etc/sysconfig/network-scripts/route-ens192
systemctl stop firewalld
systemctl disable firewalld
systemctl stop iptables
systemctl disable iptables
systemctl restart network

subscription-manager unregister
subscription-manager register --username coc_europa --password Passw0rd= --auto-attach --force
subscription-manager refresh
subscription-manager attach --pool=8a85f9996c535260016c535f83b001e6
subscription-manager repos --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms" \
    --enable=rh-gluster-3-client-for-rhel-7-server-rpms
yum clean all
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
yum -y install docker openshift-ansible
yum -y install glusterfs glusterfs-client-xlators glusterfs-libs glusterfs-fuse heketi-client nfs-utils

systemctl restart docker

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







