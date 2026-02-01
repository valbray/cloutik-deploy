#!/bin/bash

# --- COULEURS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   LANCEMENT CLOUTIK (ÉTAPE 2/2)              ${NC}"
echo -e "${BLUE}==============================================${NC}"

# ==============================================================================
# 1. VÉRIFICATION DES PRÉ-REQUIS (DOCKER)
# ==============================================================================
echo -e "Vérification de l'environnement..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERREUR] Docker n'est pas installé sur ce serveur.${NC}"
    echo -e "Veuillez l'installer (ex: curl -fsSL https://get.docker.com | sh)"
    exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "[ERREUR] Docker Compose n'est pas détecté."
  echo "Installez docker-compose-plugin (Compose v2) ou docker-compose (v1)."
  exit 1
fi
echo -e "${GREEN}[OK] Docker et Docker Compose sont présents.${NC}"

# ==============================================================================
# 2. VÉRIFICATION DE LA CONFIGURATION
# ==============================================================================
if [ ! -f .env ]; then
    echo -e "\n${RED}[ERREUR] Fichier .env manquant.${NC}"
    echo -e "${YELLOW}Veuillez d'abord exécuter le script de configuration :${NC}"
    echo -e "./install.sh"
    exit 1
fi

# ==============================================================================
# 5. LANCEMENT DE LA STACK
# ==============================================================================
echo -e "\n${BLUE}Téléchargement des images (Pull)...${NC}"
docker-compose pull

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERREUR] Impossible de télécharger les images.${NC}"
    exit 1
fi

echo -e "\n${BLUE}Démarrage des services...${NC}"
docker-compose up -d --remove-orphans

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   APPLICATION DÉMARRÉE AVEC SUCCÈS !         ${NC}"
echo -e "${GREEN}==============================================${NC}"