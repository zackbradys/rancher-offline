### Set Variables
export vHarvester=1.2.1

### Setup Working Directory
rm -rf /opt/hauler/harvester
mkdir -p /opt/hauler/harvester
cd /opt/hauler/harvester

### Download Harvester Images
### https://github.com/harvester/harvester
curl -#L https://github.com/harvester/harvester/releases/download/v${vHarvester}/harvester-images-list.txt -o harvester-images.txt
sed -i "/^\s*#/d" harvester-images.txt && sed -i "/^$/d" harvester-images.txt && sed -i "s#^#    - name: #" harvester-images.txt

### Set Harvester Images Variable
harvesterImages=$(cat harvester-images.txt)

### Create Hauler Manifest
cat << EOF >> /opt/hauler/harvester/rancher-airgap-harvester.yaml
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: rancher-airgap-files-harvester
spec:
  files:
    - path: https://releases.rancher.com/harvester/v${vHarvester}/harvester-v${vHarvester}-amd64.iso
      name: harvester-v${vHarvester}-amd64.iso
    - path: https://releases.rancher.com/harvester/v${vHarvester}/harvester-v${vHarvester}-vmlinuz-amd64
      name: harvester-v${vHarvester}-vmlinuz-amd64
    - path: https://releases.rancher.com/harvester/v${vHarvester}/harvester-v${vHarvester}-rootfs-amd64.squashfs
      name: harvester-v${vHarvester}-rootfs-amd64.squashfs
    - path: https://releases.rancher.com/harvester/v${vHarvester}/harvester-v${vHarvester}-amd64.sha512
      name: harvester-v${vHarvester}-amd64.sha512
    - path: https://releases.rancher.com/harvester/v${vHarvester}/version.yaml
      name: version.yaml
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: rancher-airgap-images-harvester
spec:
  images:
${harvesterImages}
EOF