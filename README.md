|CI tests|galaxy releases|
|--------|---------------|
|[![CI tests](https://github.com/scicore-unibas-ch/ansible-role-slurm/workflows/CI/badge.svg)](https://github.com/scicore-unibas-ch/ansible-role-slurm/actions)|[![galaxy releases](https://img.shields.io/github/release/scicore-unibas-ch/ansible-role-slurm.svg)](https://galaxy.ansible.com/scicore/slurm/releases/)|

scicore.slurm
=========

Configure a SLURM cluster

This role will configure:
  * slurm accounting daemon
  * slurm master daemon
  * slurm worker nodes
  * slurm submit hosts

Slurm users are automatically added to the slurm accounting db on the first job submission using 
a [lua job submission plugin](templates/job_submit.lua.j2)


Example inventory
===================

```
master ansible_host=192.168.56.100 ansible_user=vagrant ansible_password=vagrant
submit ansible_host=192.168.56.101 ansible_user=vagrant ansible_password=vagrant
compute ansible_host=192.168.56.102 ansible_user=vagrant ansible_password=vagrant

[slurm_submit_hosts]
submit

[slurm_workers]
compute
```

**Once you define your inventory make sure to define var "slurm_master_host" pointing to the hostname of your master host**

Role Variables
--------------

```
# add all the slurm hosts to /etc/hosts in every machine
# ips come from ansible facts hostvars[ansible_hostname]['ansible_default_ipv4']['address']
slurm_update_etc_hosts_file: true

# point this var to a git repo if you have your slurm config in git
# slurm_config_git_repo: ""

# by default the role will deploy a lua submit plugin which will automatically add the users to the slurm accounting db
# Check "templates/job_submit.lua.j2" for details
slurm_config_deploy_lua_submit_plugin: true

# Use slurm configless https://slurm.schedmd.com/configless_slurm.html
# This feature requires slurm 20.02 or higher
# Only tested on RedHat systems but it should work on Ubuntu too if you install ubuntu20.02 or higher
slurm_configless: false

# Deploy required scripts in slurm master for cloud scheduling using openstack (https://slurm.schedmd.com/elastic_computing.html)
# This will deploy "ResumeProgram", "SuspendProgram" for slurm.conf
# and /etc/openstack/clouds.yaml with an application credential in the slurm master
# This requires a custom slurm.conf. Check "templates/slurm.conf.j2.cloud.example" for an example
# It's recommended to use [OpenStack's internal DNS resolution] (https://docs.openstack.org/neutron/latest/admin/config-dns-int.html#the-networking-service-internal-dns-resolution) 
slurm_openstack_cloud_scheduling: false
slurm_openstack_venv_path: /opt/venv_slurm
slurm_openstack_auth_url: https://my-openstack-cloud.com:5000/v3
slurm_openstack_application_credential_id: "4eeabeabcabdwe19451e1d892d1f7"
slurm_openstack_application_credential_secret: "supersecret1234"
slurm_openstack_region_name: "RegionOne"
slurm_openstack_interface: "public"
slurm_openstack_identity_api_version: 3
slurm_openstack_auth_type: "v3applicationcredential"

# slurm cluster name as defined in slurm.cfg
slurm_cluster_name: slurm-cluster

# set this var to the ansible_hostname of the slurm-master
slurm_master_host: slurm-master.cluster.com
# set this var to the ansible_hostname of the slurm-dbd host (same as slurm-master by default)
slurm_dbd_host: "{{ slurm_master_host }}"

# group in your ansible inventory including all the slurm workers
slurm_workers_group: slurm_workers

# group in your ansible inventory including all the submit hosts
slurm_submit_group: slurm_submit_hosts

# this is the setting "StateSaveLocation" in slurm.conf
slurm_slurmctld_spool_path: /var/spool/slurmctld

# this is the setting "SlurmdSpoolDir" in slurm.conf
slurm_slurmd_spool_path: /var/spool/slurmd

# settings for the slurm accounting daemon
slurm_slurmdbd_mysql_db_name: slurm
slurm_slurmdbd_mysql_user: slurm
slurm_slurmdbd_mysql_password: aadAD432saAdfaoiu

# slurm user and group which runs the slurm daemons
slurm_user:
  RedHat: "root"
  Debian: "slurm"

slurm_group:
  RedHat: "root"
  Debian: "slurm"

# EPEL is required to install slurm packages and some dependencies on CentOS/RedHat systems.
slurm_add_epel_repo: true

# You can set this to true to enable the openhpc yum repos on centos
# If you plan to use packages from openhpc you should also update the list of packages for RedHat below
slurm_add_openhpc_repo: false
slurm_ohpc_repos_url:
  rhel7: "https://github.com/openhpc/ohpc/releases/download/v1.3.GA/ohpc-release-1.3-1.el7.x86_64.rpm"
  rhel8: "http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm"

# slurm packages we install in every cluster member
slurm_packages_common:
  RedHat:
    - slurm
    - slurm-doc
    - slurm-contribs
  Debian:
    - slurm-client

# slurm packages we install only in master node
slurm_packages_master:
  RedHat:
    - slurm-slurmctld
    #  - slurm-slurmrestd
  Debian:
    - slurmctld

# slurm packages we install only in slurmdbd node
slurm_packages_slurmdbd:
  RedHat:
    - slurm-slurmdbd
    - mariadb-server
  Debian:
    - slurmdbd
    - mariadb-server

# slurm packages we install only in worker nodes
slurm_packages_worker:
  RedHat:
    - slurm-slurmd
    - vte-profile  # avoid error message "bash __vte_prompt_command command not found" on slurm interative shells
  Debian:
    - slurmd
```
