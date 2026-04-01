#!/bin/bash

#################################################################
# Nome do Script: deploy_webserver.sh
# Descrição: Automatiza o provisionamento de uma instância EC2 
#            Web Server via AWS CLI através de um Bastion Host.
# Autor: Seu Nome
# Data: 01/04/2026
#################################################################

echo "Iniciando o processo de automação do Servidor Web..."

# 1. Configuração de Região e Busca da AMI mais recente (Amazon Linux 2)
echo "Recuperando metadados da instância e ID da AMI..."
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_DEFAULT_REGION=${AZ::-1}

AMI=$(aws ssm get-parameters \
    --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
    --query 'Parameters[0].[Value]' \
    --output text)

echo "AMI selecionada: $AMI"

# 2. Recuperação de IDs de Rede (Subnet e Security Group)
echo "Identificando Subnet Pública e WebSecurityGroup..."
SUBNET=$(aws ec2 describe-subnets \
    --filters 'Name=tag:Name,Values=Public Subnet' \
    --query Subnets[].SubnetId \
    --output text)

SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=WebSecurityGroup \
    --query SecurityGroups[].GroupId \
    --output text)

echo "Configurações encontradas: Subnet ($SUBNET) | Security Group ($SG)"

# 3. Download do Script de User Data (Configuração de inicialização)
echo "Baixando script de inicialização (User Data)..."
wget -q https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-RSJAWS-1-23732/171-lab-JAWS-create-ec2/s3/UserData.txt -O UserData.txt

# 4. Execução (Launch) da Instância EC2
echo "Lançando a instância Web Server..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI \
    --subnet-id $SUBNET \
    --security-group-ids $SG \
    --user-data file://UserData.txt \
    --instance-type t3.micro \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Web Server}]' \
    --query 'Instances[*].InstanceId' \
    --output text)

echo "Sucesso! Instância criada com ID: $INSTANCE_ID"

# 5. Monitoramento e Link Final
echo "Aguardando a instância entrar em estado 'running'..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_DNS=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query Reservations[].Instances[].PublicDnsName \
    --output text)

echo "----------------------------------------------------------"
echo "O Servidor Web está online!"
echo "URL de acesso: http://$PUBLIC_DNS"
echo "----------------------------------------------------------"