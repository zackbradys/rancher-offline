### Set Variables
export vHauler=0.4.3

### Setup Working Directory
rm -rf /opt/rancher/hauler/hauler
mkdir -p /opt/rancher/hauler/hauler
cd /opt/rancher/hauler/hauler

### Create Hauler Manifest
### Hauler -> https://github.com/rancherfederal/hauler
cat << EOF >> /opt/rancher/hauler/hauler/rancher-airgap-hauler.yaml
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: rancher-airgap-files-hauler
spec:
  files:
    - path: https://github.com/rancherfederal/hauler/releases/download/v${vHauler}/hauler_${vHauler}_linux_amd64.tar.gz
      name: hauler
EOF