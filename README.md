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


# Example inventory

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

# Role Variables

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

# Configuring slurm cloud scheduling for OpenStack

This role can configure your slurm cluster to use cloud scheduling on an OpenStack cloud. 

Before you try to configure it it's recommeded to read the [Slurm's cloud scheduling guide](https://slurm.schedmd.com/elastic_computing.html) and
[Slurm's configless docs](https://slurm.schedmd.com/configless_slurm.html)

Make sure that your OpenStack cloud has [internal DNS resolution](https://docs.openstack.org/neutron/latest/admin/config-dns-int.html#the-networking-service-internal-dns-resolution) enabled.
This is required so when a new node is booted its hostname can be resolved by the slurm master using the OpenStack internal DNS.

You should also check the example config file [slurm.conf.j2.cloud.example](templates/slurm.conf.j2.cloud.example) provided with this role. 
**slurm.conf.j2.cloud.example is provided as an example and you will need to adapt it to your specific needs and point the ansible var slurm_conf_custom_template to your custom config**

## Cloud scheduling config overview

* As described in the slurm cloud scheduling docs, when a user submits a job to a cloud node the slurm master will execute the "ResumeProgram" defined in slurm.conf to boot the compute node in the cloud. 

* The [ResumeProgram provided with this role](templates/slurm_resume_openstack.py.j2) is a python script which will use the OpenStack API to boot the compute nodes. This python script requires
the OpenStack client, which is installed inside a virtualenv. The argument to the program is the names of nodes (using Slurm's hostlist expression format) to power up.

* When a compute node is idle the slurm master will execute the [SuspendProgram](templates/slurm_suspend_openstack.py.j2) to stop the nodes. The argument to the program is the names of nodes (using Slurm's hostlist expression format) to power down.

* The flavor, image, network, keypair and security groups to be used must be defined as [node Features in slurm.conf](https://slurm.schedmd.com/slurm.conf.html#OPT_Features) e.g. `NodeName=compute-dynamic-[01-04] CPUs=4 RealMemory=7820 State=CLOUD Features=image=centos7,flavor=m1.large,keypair=key123,network=slurm_network,security_groups=default|slurm`

* Both "ResumeProgram" and "SuspendProgram" require an [OpenStack config file](https://docs.openstack.org/python-openstackclient/pike/configuration/index.html#configuration-files) with valid credentials. This file is by default populated to "/etc/openstack/clouds.yaml". It's recommeded to use an [OpenStack application credential](https://docs.openstack.org/keystone/queens/user/application_credentials.html). Check the template [templates/clouds.yaml.j2](templates/clouds.yaml.j2) to find the required ansible variables to populate this config file.

* Both "ResumeProgram" and "SuspendProgram" will write logs to "/var/log/messages" in the slurm master host. You can check this log for debugging purposes when booting cloud nodes.

## Recommended approach to deploy slurm with OpenStack cloud scheduling

Make sure you have Slum 20.02 or higher in your repositories so you have support for [slurm configless mode](https://slurm.schedmd.com/configless_slurm.html).

Boot at least 3 machines:

  * slurm master
  * slurm submit (login node)
  * slurm worker (this can be a small machine that we will use just to create an OpenStack image with the required config for the cloud compute nodes)

Populate your ansible inventory and add the machines to the right inventory groups referenced by ansible vars "slurm_submit_group" and "slurm_workers_group". Define var "slurm_master_host" with the hostname of the slurm master. Every machine in the cluster should be able to resolve this hostname to the master's ip. Every machine in the cluster must be able to connect to this machine (review your security groups and local firewall)

Create a copy of "slurm.conf.j2.cloud.example", adapt it to your needs and point ansible var "slurm_conf_custom_template" to your config file. Your config file should provide a static partition which only includes the slurm worker machine we booted before. 

Define ansible var `slurm_configless: true` so the compute nodes are configured in configless mode. When a slurm worker is configured in configless mode slurmd daemon will contact the slurm master on first boot and will download slurm.conf to `/var/run/slurm/conf/slurm.conf`

Execute the role to configure all your machines and you should get a working slurm cluster with a single node in the static partition.
 
Now you can run your custom playbooks or scripts to customize the slurm worker e.g. add NFS mounts, install LDAP client, enable software modules, install extra software..etc

Create an OpenStack image from the machine in the static partition which includes your required customizations. Check [create-slurm-compute-node-image.yml](aux-playbook/create-slurm-compute-node-image.yml) for an example.

Update your copy of "slurm.conf.j2.cloud.example" and define the proper node features with the openstack image name, key name, network name and security groups. Rerun the playbook to deploy your updated config.

Now (hopefully) you should have a working slurm cluster with cloud scheduling support. You should see the slurm cloud partitions when executing `sinfo -Nel`. Try to submit a job to one of the cloud partitions and monitor `/var/log/messages` and `/var/log/slurm/slurmctld.log` in the slurm master host.
