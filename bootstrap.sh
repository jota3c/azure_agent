#!/bin/bash
#
# Test file for bootstrap a vm has azure-agent
#

export VSTS_AGENT_INPUT_URL=${url}
export VSTS_AGENT_INPUT_AUTH=pat
export VSTS_AGENT_INPUT_TOKEN=${token}
export VSTS_AGENT_INPUT_POOL=${pool}
export VSTS_AGENT_INPUT_TERRAVERSION=${terraversion}

USER=vtsagent
GROUP=$USER

groupadd $GROUP
adduser -g $GROUP $USER

cd /home/$USER

rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
yum install -y yum-utils git scl-utils dotnet-sdk-3.1 docker
wget -O /tmp/agent.tar.gz https://vstsagentpackage.azureedge.net/agent/2.195.2/vsts-agent-linux-x64-2.195.2.tar.gz
mkdir myagent && cd myagent
tar zxvf /tmp/agent.tar.gz
./bin/installdependencies.sh
chown -R $USER:$GROUP .
su $USER -c './config.sh --unattended'
echo "HOME=/home/$USER" >> .env
./svc.sh install $USER

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform-"$VSTS_AGENT_INPUT_TERRAVERSION"

./svc.sh start

mkdir -p _work

chown -R $USER:$GROUP _work
