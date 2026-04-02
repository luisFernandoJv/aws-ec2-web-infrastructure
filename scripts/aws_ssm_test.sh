#!/bin/bash

# =================================================================
# Script: setup_webserver.sh
# Descrição: Automação de provisionamento para servidor Apache na AWS
# Autor: Luis Fernando Alexandre dos Santos
# Data: 02/04/2026
# =================================================================

# 1. Atualização dos pacotes do Sistema Operacional
echo "Iniciando atualização do sistema..."
yum update -y

# 2. Instalação do servidor web Apache (httpd)
echo "Instalando Apache..."
yum install -y httpd

# 3. Inicialização e configuração do serviço para boot automático
echo "Iniciando o serviço httpd..."
systemctl start httpd
systemctl enable httpd

# 4. Ajuste de permissões de diretório
# Garante que o usuário ec2-user possa gerenciar os arquivos web sem sudo
echo "Configurando permissões em /var/www/html..."
chown -R ec2-user:ec2-user /var/www/html
chmod -R 775 /var/www/html

# 5. Criação da página web personalizada
# Nota: Substitua o texto abaixo conforme necessário
cat <<EOF > /var/www/html/projects.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Projeto AWS - Luis Fernando</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #FF9900; }
        p { color: #555; }
    </style>
</head>
<body>
    <h1>Reiniciar o Projeto de Trabalho de Luis Fernando Alexandre dos Santos</h1>
    <p>Laboratório de Desafios de Instâncias EC2 - Infraestrutura AWS</p>
    <hr>
    <small>Servidor provisionado automaticamente via User Data Script</small>
</body>
</html>
EOF

echo "Configuração concluída com sucesso!"