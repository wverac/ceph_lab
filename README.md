# CEPH Lab
Deploy [CEPH](https://ceph.io/) home-lab with [Terrafrom](https://terraform.io) and [Ansible](https://ansible.com)

## Architecture overview
![overview](https://github.com/wverac/ceph_lab/blob/main/assets/ceph-overview-clear.png)

## Deploy the local infrastructure using terraform and libvirt as provider
This will use your default ssh key to acces to the nodes

```
~/.ssh/id_rsa.pub
```

If you want use a different key update
[terraform/user_data.cfg](terraform/user_data.cfg)

```
git clone git@github.com:wverac/ceph_lab.git
cd ceph_lab/terraform
terraform init  
terraform apply -auto-approve   
virsh list --all
```
```
 Id   Name            State
-------------------------------
 58   ceph-master     running
 59   ceph-osd-03     running
 60   ceph-mon-02     running
 61   ceph-osd-02     running
 62   ceph-osd-01     running
 63   ceph-mon-03     running
 64   ceph-mon-01     running
```
```
virsh net-list
```
```
 Name           State    Autostart   Persistent
-------------------------------------------------
 ceph-admin     active   yes         yes
 ceph-cluster   active   yes         yes
```
## Setup ansible passwords and vault

```
cd ceph_lab/ansible
```
Dont forget your **vault password**

```
ansible-vault encrypt_string --ask-vault-pass "YOUR_GRAFANA_SUPERPASSWORD_HERE" --name grafana_admin_password
ansible-vault encrypt_string --ask-vault-pass "YOUR_DASHBOARD_SUPERPASSWORD_HERE" --name dashboard_admin_password
```
Edit [ansible/all.yml](ansible/all.yml), example:

```yaml
grafana_admin_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  31303161623866646562623263623165636566343831363237633763653261353161303732303932
  6461623432363937336237316231626330613364613432660a303565376233386666383432636430
  66346236616266313537346233346632326266333265616331663562386465313362346239383466
  6130326637333337370a323164393635306138303863343438313633643463623862666135633837
  6461

dashboard_admin_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  63626565353636643433343736376535316333333963373061633739303430646239656136323663
  6662333930363431663238343537623865373266316565630a663231373565653163623138313539
  66363131353761663462643162666566316265653266353337323636333365646361333565646232
  6139323862653165390a353661616437313764626166363066316161323464363961333132353338
  6463
```
Create your vault password file
```
 echo "YOUR_VAULTPASSWORD_HERE" >  vault-passwd
 chmod 600 vault-passwd
```
## Setup nodes and deploy

```
cd ceph_lab/ansible
ansible-playbook ceph-deploy.yml 
```
ssh to ceph-mon-01

 ```
ssh cloud@192.168.100.30  
```

```
cloud@ceph-mon-01:~$ sudo ceph status
  cluster:
    id:     904a2f36-115a-4f81-9ea7-f306ea9c28f1
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-mon-01,ceph-mon-02,ceph-mon-03 (age 21m)
    mgr: ceph-mon-01(active, since 13m)
    osd: 9 osds: 9 up (since 19m), 9 in (since 19m)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    pools:   5 pools, 129 pgs
    objects: 198 objects, 455 KiB
    usage:   448 MiB used, 225 GiB / 225 GiB avail
    pgs:     129 active+clean

cloud@ceph-mon-01:~$
```
```
cloud@ceph-mon-01:~$ sudo ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    225 GiB  225 GiB  448 MiB   448 MiB       0.19
TOTAL  225 GiB  225 GiB  448 MiB   448 MiB       0.19

--- POOLS ---
POOL                 ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                  1    1  449 KiB        2  1.3 MiB      0     71 GiB
.rgw.root             2   32  1.6 KiB        6   72 KiB      0     71 GiB
default.rgw.log       3   32  3.6 KiB      178  408 KiB      0     71 GiB
default.rgw.control   4   32      0 B        8      0 B      0     71 GiB
default.rgw.meta      5   32    824 B        4   48 KiB      0     71 GiB
cloud@ceph-mon-01:~$
```
You can also access to the dashboard trough 
```
https://localhost:8443
```
![ceph_dashboard](https://github.com/wverac/ceph_lab/blob/main/assets/ceph-dashboard.png)

w00t!
