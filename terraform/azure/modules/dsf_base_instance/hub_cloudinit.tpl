#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
sudo yum update -y
sudo yum install unzip -y
sudo yum install jq -y
sudo yum install lvm2 -y
sudo mkdir -p /opt/
sudo yum install dnf -y

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
sudo dnf install azure-cli -y

# sudo pvcreate -ff /dev/nvme1n1 -y
# sudo vgcreate data /dev/nvme1n1 
# sudo lvcreate -n vol0 -l 100%FREE data -y
# sudo mkfs.xfs /dev/mapper/data-vol0
# echo "$(blkid /dev/mapper/data-vol0 | cut -d ':' -f2 | awk '{print $1}') /opt xfs defaults 0 0" | sudo tee -a /etc/fstab
# sudo mount -a
