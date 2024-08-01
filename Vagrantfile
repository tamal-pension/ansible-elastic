# -*- mode: ruby -*-
# vi: set ft=ruby :
# vagrant plugin install vagrant-aws 
## optional:
# export COMMON_COLLECTION_PATH='~/git/opinion-ansible/ansible-common-collection'
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws

TOPIC_NAME = "pre_playbook_errors"
ACCOUNT_ID = "339712742264"
AWS_REGION = "eu-west-1"
ES_CLUSTER = 'pension-test-#{Etc.getpwuid(Process.uid).name}'
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL  
    set -euo pipefail
    export ANSIBLE_VERBOSITY=0
    echo "start vagrant file"
    cd /vagrant
    aws s3 cp s3://resource-pension-stg/get-pip.py - | python3
    mkdir /vagrant/deployment
    chmod -R 755 /vagrant/deployment  
    cd /vagrant/deployment
    aws s3 cp s3://bootstrap-pension-stg/playbooks/ansible-elasticsearch/latest/ /vagrant/deployment --recursive --region eu-west-1 --exclude '.*' --exclude '*/.*'
    echo $PWD
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-pension-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2023.sh | bash -s -- -r #{AWS_REGION} -e "playbook_name=ansible-elasticsearch es_discovery_cluster=#{ES_CLUSTER} discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}" --topic-name #{TOPIC_NAME} --account-id #{ACCOUNT_ID}
    #curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2023.sh | bash -s -- -r eu-west-1 -e "playbook_name=ansible-elasticsearch es_discovery_cluster=pension-test discord_message_owner_name=terra" --topic-name pre_playbook_errors --account-id 339712742264
    rm vault_password
  SHELL

  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.access_key_id             = `op read "op://Security/aws pension-stg/Security/Access key ID"`.strip!
    aws.secret_access_key         = `op read "op://Security/aws pension-stg/Security/Secret access key"`.strip!
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','ansible-galaxy/'], disabled: false
    collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    override.vm.synced_folder collection_path, '/vagrant/ansible-galaxy', type: :rsync, rsync__exclude: '.git/', disabled: false

    aws.region = AWS_REGION
    aws.security_groups = ["sg-077f8d7d58d420467"]
    aws.ami = "ami-0fa86d752d8b7d1ff"
    aws.instance_type = "r6g.medium"
    aws.subnet_id = "subnet-0a5b54a2e357621e5"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      #private_dns: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      #node_data: "true"
      #node_master: "true",
      #initial_master_nodes: "",
      #seed_hosts: "elastic-test" 
    }
  end
end
# aws.security_groups = ["sg-049e1c31339a364a6", "sg-0fa99390aabcd150c", "sg-0ad49a7b6b83d061f"]
# public-ssh, backend, elastic