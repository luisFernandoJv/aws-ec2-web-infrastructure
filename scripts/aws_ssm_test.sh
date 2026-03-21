#!/bin/bash

# ==============================================================================
# Script: aws_ssm_test.sh
# Descrição: Automação de coleta de metadados e validação de permissões via SSM.
# Autor: Luis Fernando Alexandre dos Santos
# Data: 2026-03-20
# ==============================================================================

echo "--- Iniciando Validação de Instância via Session Manager ---"

# 1. Verificação de arquivos da aplicação (Tarefa 2)
echo "[INFO] Verificando diretório root do servidor Apache..."
if [ -d "/var/www/html" ]; then
    ls -F /var/www/html
    echo "[SUCCESS] Aplicação instalada corretamente via Run Command."
else
    echo "[ERROR] Diretório /var/www/html não encontrado. Verifique o Run Command."
fi

echo "------------------------------------------------------------"

# 2. Coleta de Metadados via IMDS (Tarefa 4)
echo "[INFO] Consultando Instance Metadata Service (169.254.169.254)..."

# Obtendo a Availability Zone (AZ)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

if [ -z "$AZ" ]; then
    echo "[ERROR] Falha ao consultar metadados. Verifique se o IMDS está habilitado."
else
    # Formatando AZ para extrair a Região (Ex: us-east-1a -> us-east-1)
    export AWS_DEFAULT_REGION=${AZ::-1}
    echo "[SUCCESS] Região detectada: $AWS_DEFAULT_REGION"
fi

echo "------------------------------------------------------------"

# 3. Teste de Permissões de IAM Role
echo "[INFO] Consultando recursos EC2 via AWS CLI..."
# O comando abaixo valida se a Instance Profile tem permissão de leitura
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, State.Name]' --output table

echo "--- Validação Concluída com Sucesso ---"