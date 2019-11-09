#####################################################################
## Build an OCP311 Cluster
#####################################################################

provider "vsphere" {
  user                 = "Administrator@vsphere.local"
  password             = "4!0XkF!n"
  vsphere_server       = "10.134.214.130"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "datacenter1"
}

data "vsphere_resource_pool" "pool" {
  name          = "gold"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "management-share"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "SDDC-DPG-Mgmt"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Templates/rhel75"
  datacenter_id = data.vsphere_datacenter.dc.id
}

variable "master_hostname" {
  type        = string
  default     = "master"
  description = "blah"
}

variable "ssh_user" {
  type        = string
  default     = "root"
  description = "Ansible user context"
}

variable "folder_name" {
  type        = string
  default     = "OpenShift"
  description = "folder name for the vms"
}

variable "network_route1" {
  type        = string
  default     = "10.0.0.0"
  description = "network route 1"
}

variable "network_route2" {
  type        = string
  default     = "0.0.0.0"
  description = "network route 1"
}

variable "network_netmask1" {
  type        = string
  default     = "255.0.0.0"
  description = "network mask 1"
}

variable "network_netmask2" {
  type        = string
  default     = "0.0.0.0"
  description = "network mask 0"
}

variable "network_gateway1" {
  type        = string
  default     = "10.134.214.129"
  description = "network gateway 1"
}

variable "network_gateway2" {
  type        = string
  default     = "10.134.214.137"
  description = "network gateway 1"
}

// start address of the master VMs
variable "cluster_network" {
  type = string
  default = "10.134.214.0/24"
}

// root password
variable "root_password" {
  type = string
  default = "Passw0rd="
}

// number of bastion VMs
variable "bastion_count" {
  type = string
  default = "1"
}
// number of master VMs
variable "master_count" {
  type = string
  default = "1"
}

// number of node VMs
variable "node_count" {
  type = string
  default = "2"
}

// number of infrastructure VMs
variable "infra_count" {
  type = string
  default = "3"
}

// start address of the master VMs
variable "bastion_ip_start" {
  type = string
  default = 145
}

// start address of the master VMs
variable "master_ip_start" {
  type = string
  default = 155
}

// start address of the node VMs
variable "node_ip_start" {
  type = string
  default = 157
}

// start address of the infra VMs
variable "infra_ip_start" {
  type = string
  default = 160
}

// cluster_prefix
variable "cluster_prefix" {
  type = string
  default = "ocp"
}

// Slack channel ID
variable "slack_channel" {
  type = string
  default = "T14HBABL5/BMCF0R41F/eS97vyUFG6K5KgbGBovwvQBj"
}

// bastion_memory
variable "bastion_memory" {
  type    = string
  default = "4096"
}

// master_memory
variable "master_memory" {
  type    = string
  default = "16384"
}

// node_memory
variable "node_memory" {
  type    = string
  default = "12288"
}

// infra_memory
variable "infra_memory" {
  type    = string
  default = "12288"
}

// disk1-name
variable "disk1-name" {
  type    = string
  default = "/dev/sdb"
}

// disk2-name
variable "disk2-name" {
  type    = string
  default = "/dev/sdc"
}

// disk3-name
variable "disk3-name" {
  type    = string
  default = "/dev/sdd"
}

// bastion_disk1
variable "bastion_disk1" {
  type    = string
  default = "256"
}

// master_disk1
variable "master_disk1" {
  type    = string
  default = "128"
}

// master_disk2
variable "master_disk2" {
  type    = string
  default = "4"
}

// master_disk3
variable "master_disk3" {
  type    = string
  default = "4"
}

// node_disk1
variable "node_disk1" {
  type    = string
  default = "128"
}

// node_disk2
variable "node_disk2" {
  type    = string
  default = "4"
}

// node_disk3
variable "node_disk3" {
  type    = string
  default = "4"
}

// infra_disk1
variable "infra_disk1" {
  type    = string
  default = "128"
}

// infra_disk2
variable "infra_disk2" {
  type    = string
  default = "4"
}

// infra_disk3
variable "infra_disk3" {
  type    = string
  default = "4"
}

// The domain name to set up each virtual machine as.
variable "virtual_machine_domain" {
  type = string
  default = "coc.net"
}

// netmask
variable "virtual_machine_netmask" {
  type    = string
  default = "26"
}

// The default gateway for the network the virtual machines reside in.
variable "virtual_machine_gateway" {
  type    = string
  default = "10.134.214.137"
}

// The default DNS servers
variable "virtual_machine_dns_servers" {
  type    = list(string)
  default = ["8.8.8.8"]
}

variable "address0" {
  type	  = string
  default = "10.0.0.0"
}

variable "netmask0" {
  type	  = string
  default = "255.0.0.0"
}

variable "gateway0" {
  type	  = string
  default = "10.134.214.129"
}
