#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
sudo yum update -y
sudo yum install unzip -y
sudo yum install jq -y
sudo yum install lvm2 -y
sudo mkdir -p /opt/
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mount -o rw,defaults /dev/sdb /opt

# Download installation file
gcloud storage cp gs://${gcp_bucket_name}/${dsf_install_tarball_path} .

sudo groupadd sonar
sudo useradd -g sonar sonarw 
sudo useradd -g sonar sonargd
        
# Installation
tar -xzvf ${dsf_install_tarball_path} -C /opt
rm ${dsf_install_tarball_path}
chown -R sonarw:sonar /opt/jsonar

# Installing sonar sw as a hub
STATE_DIR=/opt/jsonar
/opt/jsonar/apps/${dsf_version}/bin/sonarg-setup --no-interactive \
    --accept-eula \
    --jsonar-uid-display-name "${name}" \
    --jsonar-uid "${uuid}" \
    --not-remote-machine \
    --product imperva-data-security \
    --newadmin-pass=${admin_password} \
    --secadmin-pass=${secadmin_password} \
    --sonarg-pass=${sonarg_pasword} \
    --sonargd-pass=${sonargd_pasword} \
    --jsonar-datadir=$STATE_DIR/data \
    --jsonar-localdir=$STATE_DIR/local \
    --jsonar-logdir=$STATE_DIR/logs ${additional_parameters}

# export $(cat /etc/sysconfig/jsonar)

# mkdir -p /home/sonarw/.ssh/
# /usr/local/bin/aws secretsmanager get-secret-value --secret-id {dsf_hub_private_key_name} --query SecretString --output text > /root/.ssh/id_rsa
# /usr/local/bin/aws secretsmanager get-secret-value --secret-id {dsf_hub_public_key_name} --query SecretString --output text > /root/.ssh/id_rsa.pub
# /usr/local/bin/aws secretsmanager get-secret-value --secret-id {dsf_hub_private_key_name} --query SecretString --output text > /home/sonarw/.ssh/id_rsa
# /usr/local/bin/aws secretsmanager get-secret-value --secret-id {dsf_hub_public_key_name} --query SecretString --output text > /home/sonarw/.ssh/id_rsa.pub

# # iterate over list of gateway public keys and add to authorized_keys
# auth_keys=$(echo "{dsf_gateway_public_authorized_keys}" | tr ";|;" "\n")
# for auth_key in $auth_keys
# do
#     /usr/local/bin/aws secretsmanager get-secret-value --secret-id $auth_key --query SecretString --output text >> /root/.ssh/authorized_keys
#     /usr/local/bin/aws secretsmanager get-secret-value --secret-id $auth_key --query SecretString --output text >> /home/sonarw/.ssh/authorized_keys
# done

# chmod 600 /root/.ssh/id_rsa*
# chown -R sonarw:sonar /home/sonarw
# chmod 600 /home/sonarw/.ssh/id_rsa*