## Internet Connected Server

Complete the following commands on the Internet Connected Server. For the initial airgap, we recommend you bring all components over the airgap and then individual components as required in the future.

```bash
### Set Variables
export vRancherAirgap=0.7.3

### Fetch Individual Hauler TARs
mkdir -p /opt/rancher/hauler
cd /opt/rancher/hauler

curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/hauler/rancher-airgap-hauler.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rke2/rancher-airgap-rke2.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/rancher/rancher-airgap-rancher.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/longhorn/rancher-airgap-longhorn.tar.zst
curl -#OL https://rancher-airgap.s3.amazonaws.com/${vRancherAirgap}/hauler/neuvector/rancher-airgap-neuvector.tar.zst

### Optional: Create Single Hauler TAR
tar -czvf /opt/rancher/hauler/rancher-airgap.tar.zst .
```

---

**MOVE TAR(s) ACROSS THE AIRGAP**

---

## Disconnected Server

Complete the following commands on the Disconnected Server. We recommend you do **not** use this server as one of the nodes in the cluster.

### Setup Server with Hauler
```bash
### Install OS Packages
### There are many ways to airgap packages, please refer to other guides.
yum install -y zip zstd tree jq iptables container-selinux iptables libnetfilter_conntrack libnfnetlink libnftnl policycoreutils-python-utils cryptsetup
yum install -y nfs-utils && yum install -y iscsi-initiator-utils && echo "InitiatorName=$(/sbin/iscsi-iname)" > /etc/iscsi/initiatorname.iscsi && systemctl enable --now iscsid
echo -e "[keyfile]\nunmanaged-devices=interface-name:cali*;interface-name:flannel*" > /etc/NetworkManager/conf.d/rke2-canal.conf

### Setup Directories
mkdir -p /opt/rancher/hauler
cd /opt/rancher/hauler

### Untar Hauler
tar -xf /opt/rancher/hauler/rancher-airgap-hauler.tar.zst
rm -rf README.md hauler_0.3.0_linux_amd64.tar.gz && mv hauler /usr/bin/hauler

### Import Hauler TARs (will take a minute)
hauler store load rancher-airgap-rke2.tar.zst rancher-airgap-rancher.tar.zst rancher-airgap-longhorn.tar.zst rancher-airgap-neuvector.tar.zst

### Verify Hauler Store
hauler store info

### Create Hauler Registry Directory Structure (will show errors)
hauler store serve

### Serve Hauler Registry (serves the oci compliant registry)
hauler serve registry -r registry
```

### Configure and Install Rancher RKE2 Nodes

#### Rancher RKE2 Server Node (Control Plane)
```bash
### Set Variables
export vRKE2=1.25.12
export vPlatform=el9
export IP=3.89.28.28

### Verify Registry Contents
### Replace $IP with Server IP
curl -X GET $IP:5000/v2/_catalog

### Setup Directories
mkdir -p /etc/rancher/rke2
cd /opt/rancher/hauler

### Extract RKE2 Contents from Hauler
hauler store extract hauler/rke2-selinux-0.14-1.${vPlatform}.noarch.rpm:latest
hauler store extract hauler/rke2-common-${vRKE2}.rke2r1-0.${vPlatform}.x86_64.rpm:latest
hauler store extract hauler/rke2-server-${vRKE2}.rke2r1-0.${vPlatform}.x86_64.rpm:latest

### Install RKE2 SELinux Package
yum install -y rke2-selinux-0.14-1.${vPlatform}.noarch.rpm rke2-common-${vRKE2}.rke2r1-0.${vPlatform}.x86_64.rpm rke2-server-${vRKE2}.rke2r1-0.${vPlatform}.x86_64.rpm

### Configure RKE2 Config
### Replace $IP with Server IP
cat << EOF >> /etc/rancher/rke2/config.yaml
token: RancherAirgapRKE2token
system-default-registry: $IP:5000
EOF

### Configure Local Registry
### Replace $IP with Server IP
cat << EOF >> /etc/rancher/rke2/registries.yaml
mirrors:
  "$IP:5000":
    endpoint:
      - "http://$IP:5000"
  "docker.io":
    endpoint:
      - "http://$IP:5000"
EOF

### Enable/Start RKE2 Server
systemctl enable --now rke2-server.service

### Symlink kubectl and containerd
sudo ln -s /var/lib/rancher/rke2/data/v1*/bin/kubectl /usr/bin/kubectl
sudo ln -s /var/run/k3s/containerd/containerd.sock /var/run/containerd/containerd.sock

### Update BASHRC with KUBECONFIG/PATH
cat << EOF >> ~/.bashrc
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/
EOF

### Source BASHRC
source ~/.bashrc

### Verify Node
kubectl get nodes -o wide
```

#### Rancher RKE2 Agent Nodes (Workers)
```bash

```
WIP WIP WIP