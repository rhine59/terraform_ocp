locals {
    ssh_user = "${var.ssh_user}"
}

data  "template_file" "k8s" {
    template = "${file("./templates/k8s.tpl")}"
    vars = {
        k8s_master_name = "${join("\n", vsphere_virtual_machine.master.*.name)}"
        k8s_etcd_name = "${join("\n", vsphere_virtual_machine.master.*.name)}"
        k8s_node_name = "${join("\n", vsphere_virtual_machine.node.*.name)}"
        k8s_infra_name = "${join("\n", vsphere_virtual_machine.infra.*.name)}"
    }
}

resource "local_file" "k8s_file" {
  content  = "${data.template_file.k8s.rendered}"
  filename = "./inventory/k8s-host"
}
