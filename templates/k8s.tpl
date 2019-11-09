[OSEv3:children]
masters
etcd
nodes

[OSEv3:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_user=root
openshift_deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

[masters]
${k8s_master_name}

[etcd]
${k8s_etcd_name}

[nodes]
${k8s_master_name} openshift_node_group_name='node-config-master'
${k8s_master_name} openshift_node_group_name='node-config-etcd'
${k8s_node_name} openshift_node_group_name='node-config-compute'
${k8s_infra_name} openshift_node_group_name='node-config-infra'

