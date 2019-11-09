#!/bin/sh
terraform taint null_resource.install-master
terraform taint vsphere_virtual_machine.master
echo yes|terraform apply
