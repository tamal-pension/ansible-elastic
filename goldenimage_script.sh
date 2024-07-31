#!/usr/bin/env bash
REGION=$(ec2-metadata --availability-zone | sed -n 's/.*placement: \([a-zA-Z-]*[0-9]\).*/\1/p');
echo "region:$REGION"

PARAMETER=$(aws ssm get-parameter --name "UserDataYAMLConfig" --query "Parameter.Value" --output text --region $REGION)

METADATA_REQUEST='TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance'

GET_PIP_URL=$(echo "$PARAMETER" | grep 'get_pip_url' | awk '{print $2}')
echo "Get Pip URL: $GET_PIP_URL"

PLAYBOOK_BASE_URL=$(echo "$PARAMETER" | grep 'playbook_base_url' | awk '{print $2}')
echo "Playbook Base URL: $PLAYBOOK_BASE_URL"

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $ACCOUNT_ID"

PLAYBOOK_NAME=$(eval $METADATA_REQUEST/playbook_name)
echo "playbook_name:$PLAYBOOK_NAME"

TOPIC_NAME=$(echo "$PARAMETER" | grep 'topic_name' | awk '{print $2}')
echo "Topic Name: $TOPIC_NAME"

SECRET_NAME="vault_secret"
VAULT_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --region $REGION --query 'SecretString' --output text)

catch_error () {
    INSTANCE_ID=$(ec2-metadata --instance-id | sed -n 's/.*instance-id: \(i-[a-f0-9]\{17\}\).*/\1/p')
    echo "An error occurred in goldenimage_script: $1"
    aws sns publish --topic-arn "arn:aws:sns:$REGION:$ACCOUNT_ID:$TOPIC_NAME" --message "$1" --subject "$INSTANCE_ID" --region $REGION
}
main () {
    set -euo pipefail
    echo "Start userdata_amzn2023.sh"
    #python3 -m venv /tmp/ansibleenv
    #source /tmp/ansibleenv/bin/activate
    aws s3 cp $GET_PIP_URL - | python3
    echo "download playbook"
    mkdir /tmp/deployment
    aws s3 cp $PLAYBOOK_BASE_URL/$PLAYBOOK_NAME/latest/ /tmp/deployment --recursive --region $REGION --exclude '.*' --exclude '*/.*'
    chmod -R 755 /tmp/deployment
    cd /tmp/deployment
    echo "execute playbook in $(pwd)"
    echo "$VAULT_PASSWORD" > vault_password
    bash main_amzn2023.sh -r $REGION --topic-name $TOPIC_NAME --account-id $ACCOUNT_ID -e "playbook_name='$PLAYBOOK_NAME' es_discovery_cluster=pension-test discord_message_owner_name=terra"
    #curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2023.sh | bash -s -- -r eu-west-1 -e "playbook_name=ansible-elasticsearch es_discovery_cluster=pension-test discord_message_owner_name=terra" --topic-name pre_playbook_errors --account-id 339712742264
    rm vault_password
    echo "End user data"
}
trap 'catch_error "$ERROR"' ERR
{ ERROR=$(main 2>&1 1>&$out); } {out}>&1