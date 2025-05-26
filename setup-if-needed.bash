#!/bin/bash

# Variáveis
PROJECT_ID="smt-the-dev-rsantos-i5qi"
PROJECT_NUMBER="890975952737"
REGION="us-central1"
FUNCTION_NAME="hello-world-function"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando configuração das permissões IAM...${NC}"

# Verificar se está autenticado
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" > /dev/null; then
    echo -e "${RED}Erro: Você precisa estar autenticado no gcloud${NC}"
    echo "Execute: gcloud auth login"
    exit 1
fi

# Verificar se o projeto está configurado
if ! gcloud config get-value project 2>/dev/null | grep -q "$PROJECT_ID"; then
    echo -e "${YELLOW}Configurando projeto padrão...${NC}"
    gcloud config set project "$PROJECT_ID"
fi

# Adicionar permissão para o Compute Engine
echo -e "${YELLOW}Adicionando permissão para o Compute Engine...${NC}"
gcloud functions add-iam-policy-binding "$FUNCTION_NAME" \
    --region="$REGION" \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/cloudfunctions.invoker" \
    --project="$PROJECT_ID"

# Adicionar permissão para o Serverless Robot
echo -e "${YELLOW}Adicionando permissão para o Serverless Robot...${NC}"
gcloud functions add-iam-policy-binding "$FUNCTION_NAME" \
    --region="$REGION" \
    --member="serviceAccount:service-${PROJECT_NUMBER}@serverless-robot-prod.iam.gserviceaccount.com" \
    --role="roles/cloudfunctions.invoker" \
    --project="$PROJECT_ID"

# Configurar o URL Map
echo -e "${YELLOW}Configurando o URL Map...${NC}"

# Primeiro, remover o URL Map existente
echo -e "${YELLOW}Removendo URL Map existente...${NC}"
gcloud compute url-maps delete hello-world-url-map --global --quiet

# Criar um novo URL Map
echo -e "${YELLOW}Criando novo URL Map...${NC}"
gcloud compute url-maps create hello-world-url-map \
    --default-service=hello-world-backend \
    --global

# Adicionar path matcher
echo -e "${YELLOW}Adicionando path matcher...${NC}"
gcloud compute url-maps add-path-matcher hello-world-url-map \
    --path-matcher-name=hello-world-matcher \
    --default-service=hello-world-backend \
    --path-rules="/helloWorld=hello-world-backend" \
    --global

# Verificar as permissões configuradas
echo -e "${YELLOW}Verificando permissões configuradas...${NC}"
gcloud functions get-iam-policy "$FUNCTION_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID"

gcloud functions add-iam-policy-binding hello-world-function \
  --region=us-central1 \
  --member="user:renatomateusx@gmail.com" \
  --role="roles/cloudfunctions.invoker"


gcloud functions add-iam-policy-binding hello-world-function \
  --region=us-central1 \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker"


echo -e "${GREEN}Configuração concluída!${NC}"
echo -e "${YELLOW}Teste a função com:${NC}"
echo "curl -v http://34.98.87.137/helloWorld" 