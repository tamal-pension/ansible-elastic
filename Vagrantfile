# -*- mode: ruby -*-
# vi: set ft=ruby :
# vagrant plugin install vagrant-aws 
## optional:
# export COMMON_COLLECTION_PATH='~/git/opinion-ansible/ansible-common-collection'
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws

MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/default/main_amzn2023.sh"
TOPIC_NAME = "pre_playbook_errors"
ACCOUNT_ID = "339712742264"
AWS_REGION = "eu-west-1"
ES_CLUSTER = "pension-test-#{Etc.getpwuid(Process.uid).name}"
MAIN_SH_ARGS = <<MARKER
-e "playbook_name=ansible-elasticsearch discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}" --tags installation
MARKER
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL  
    # set -euxo pipefail
    # echo "start vagrant file"
    # source /deployment/ansibleenv/bin/activate
    # cd /deployment/playbook
    # export ANSIBLE_VERBOSITY=0
    # export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
    # export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-pension-stg/password"`.strip!}
    # echo "$VAULT_PASSWORD" > vault_password
    # bash main.sh #{MAIN_SH_ARGS}
    # rm vault_password

    set -euxo pipefail
    echo "start vagrant file"
    python3 -m venv /tmp/ansibleenv
    source /tmp/ansibleenv/bin/activate
    aws s3 cp s3://resource-pension-stg/get-pip.py - | python3
    cd /vagrant
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault tamal-pension-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    export ANSIBLE_VERBOSITY=0
    if [ ! -f "main.sh" ]; then
    echo "Local main.sh not found. Download main.sh script from URL..."
    curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/default/main_amzn2023.sh -o main.sh
    fi
    bash main.sh #{MAIN_SH_ARGS}
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
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','inqwise/'], disabled: false
    common_collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    stacktrek_collection_path = ENV['STACKTREK_COLLECTION_PATH'] || '~/git/ansible-stack-trek'
    override.vm.synced_folder common_collection_path, '/vagrant/collections/ansible_collections/inqwise/common', type: :rsync, rsync__exclude: '.git/', disabled: false
    override.vm.synced_folder stacktrek_collection_path, '/vagrant/collections/ansible_collections/inqwise/stacktrek', type: :rsync, rsync__exclude: '.git/', disabled: false


    aws.region = AWS_REGION
    aws.security_groups = ["sg-077f8d7d58d420467"]
    aws.ami = "ami-0fa86d752d8b7d1ff"
    aws.instance_type = "t4g.medium"
    aws.subnet_id = "subnet-0331d92e81f166c9f"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      playbook_name: "ansible-elastic",
      version: "latest",
      app: "elastic",
      private_dns: "elastic-test-#{Etc.getpwuid(Process.uid).name}",
      es_cluster: ES_CLUSTER,
      node_data: "true"
      #node_master: "true",
      #initial_master_nodes: "",
      #seed_hosts: "elastic-test" 
    }
  end
end
# aws.security_groups = ["sg-049e1c31339a364a6", "sg-0fa99390aabcd150c", "sg-0ad49a7b6b83d061f"]
# public-ssh, backend, elastic