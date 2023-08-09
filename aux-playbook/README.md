## Auxiliary playbook to create an image from a running OpenStack machine

When using slurm dynamic/cloud scheduling you need to create an OpenStack image with the required settings for the compute nodes
like NFS mounts, user accounts, dynamic slurm config pointig to the slurm master, environment modules, extra packages...etc

This playbook is provided as reference to create an OpenStack image from a running server. 

**This playbook won't work for you without customization. Is provided as-is just as reference**
