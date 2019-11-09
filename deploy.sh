cd /usr/share/ansible/openshift-ansible
ansible-playbook -i /export/ocp/myhosts playbooks/deploy_cluster.yml 
#ansible-playbook -i /export/ocp/myhosts playbooks/openshift-master/config.yml -vvv
