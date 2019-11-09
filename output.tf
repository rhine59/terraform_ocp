output "bastion" {
  value = "${formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.bastion.*.name),
    (vsphere_virtual_machine.bastion.*.guest_ip_addresses.0)
  )}"
}
output "master" {
  value = "${formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.master.*.name),
    (vsphere_virtual_machine.master.*.guest_ip_addresses.0)
  )}"
}
output "node" {
  value = "${formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.node.*.name),
    (vsphere_virtual_machine.node.*.guest_ip_addresses.0)
  )}"
}
output "infra" {
  value = "${formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.infra.*.name),
    (vsphere_virtual_machine.infra.*.guest_ip_addresses.0)
  )}"
}






