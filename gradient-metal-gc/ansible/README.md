# Ansible RKE2 Cluster Setup


## Adding rancherfederal/rke2-ansible as a subtree

Roles within rancherfederal/rke2-ansible are not made available through ansible-galaxy.
The following is the setup instructions for adding the rke2-ansible roles.

```
# Add remote for rke2-ansible on the main branch
git remote add -t main --no-tags -f rke2-ansible git@github.com:rancherfederal/rke2-ansible.git

# The following is so we don't
git merge -s ours --no-commit rke2-ansible/main

# Add the individual roles into the ansible/roles dir
git read-tree --prefix=ansible/roles/rke2_agent -u rke2-ansible/main:roles/rke2_agent
git read-tree --prefix=ansible/roles/rke2_common -u rke2-ansible/main:roles/rke2_common
git read-tree --prefix=ansible/roles/rke2_server -u rke2-ansible/main:roles/rke2_server
```
