#!/bin/bash

# --- COULEURS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- FONCTION D'ANIMATION (SPINNER) ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n "  "
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

clear
echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   CLOUTIK UPDATE MANAGER                     ${NC}"
echo -e "${BLUE}==============================================${NC}"

# ==============================================================================
# 1. DÉTECTION ENVIRONNEMENT & LANGUE
# ==============================================================================
# Détection simple : Si .env contient "FR", on reste en FR, sinon EN (par défaut)
# Pour faire simple ici, on demande ou on détecte. 
# On va assumer la même logique que install.sh :
echo "  1) English"
echo "  2) Français"
read -p "Choice / Choix [1-2]: " LAN_CHOICE

if [ "$LAN_CHOICE" == "2" ]; then
    L="FR"
    T_REQ_VER="Quelle est la nouvelle version (TAG) à installer ? (ex: 1.2.0) : "
    T_BACKUP="Sauvegarde du fichier .env..."
    T_UPDATE_TAG="Mise à jour du TAG dans .env..."
    T_STOPPING="Arrêt des services en cours..."
    T_PULLING="Téléchargement de la version"
    T_START_PHASE1="[PHASE 1] Démarrage du cœur (App, DB)..."
    T_START_PHASE2="[PHASE 2] Vérification de santé..."
    T_START_PHASE3="[PHASE 3] Activation du monitoring..."
    T_WAIT_HTTP="En attente de réponse HTTP 200..."
    T_SUCCESS="Mise à jour terminée avec succès !"
    T_ERR_ENV="Fichier .env introuvable."
    T_ERR_DOCKER="Docker Compose introuvable."
else
    L="EN"
    T_REQ_VER="Which version (TAG) to install? (e.g., 1.2.0) : "
    T_BACKUP="Backing up .env file..."
    T_UPDATE_TAG="Updating TAG in .env..."
    T_STOPPING="Stopping current services..."
    T_PULLING="Pulling version"
    T_START_PHASE1="[PHASE 1] Starting Core (App, DB)..."
    T_START_PHASE2="[PHASE 2] Health Check..."
    T_START_PHASE3="[PHASE 3] Enabling Monitoring..."
    T_WAIT_HTTP="Waiting for HTTP 200 response..."
    T_SUCCESS="Update completed successfully!"
    T_ERR_ENV=".env file not found."
    T_ERR_DOCKER="Docker Compose not found."
fi

# Vérifications
if [ ! -f .env ]; then echo -e "${RED}[ERROR] $T_ERR_ENV${NC}"; exit 1; fi

if docker compose version >/dev/null 2>&1; then COMPOSE="docker compose"; 
elif command -v docker-compose >/dev/null 2>&1; then COMPOSE="docker-compose"; 
else echo -e "${RED}[ERROR] $T_ERR_DOCKER${NC}"; exit 1; fi

APP_URL=$(grep "^APP_URL=" .env | cut -d '=' -f2)
LOGIN_URL="${APP_URL}/login"
CURRENT_TAG=$(grep "^TAG=" .env | cut -d '=' -f2)

echo -e "\n${YELLOW}Current Version: $CURRENT_TAG${NC}"

# ==============================================================================
# 2. SAISIE DE LA VERSION
# ==============================================================================
# On peut passer la version en argument ./update.sh 1.0.5
if [ -n "$1" ]; then
    NEW_TAG=$1
else
    read -p "$T_REQ_VER" NEW_TAG
fi

if [ -z "$NEW_TAG" ]; then
    echo -e "${RED}Version required.${NC}"
    exit 1
fi

# ==============================================================================
# 3. MISE À JOUR .ENV
# ==============================================================================
echo -e "\n${BLUE}--- CONFIGURATION ---${NC}"

# Sauvegarde
echo -e "${CYAN}→ $T_BACKUP${NC}"
cp .env .env.bak
echo -e "${GREEN}[OK]${NC} (.env.bak)"

# Remplacement du TAG via sed
echo -ne "${CYAN}→ $T_UPDATE_TAG ($NEW_TAG)...${NC}"
# Compatible Linux (GNU sed)
sed -i "s/^TAG=.*/TAG=$NEW_TAG/" .env
echo -e "${GREEN}[OK]${NC}"

# ==============================================================================
# 4. ARRÊT ET PULL
# ==============================================================================
echo -e "\n${BLUE}--- DOCKER UPDATE ---${NC}"

# Arrêt
echo -ne "${CYAN}→ $T_STOPPING${NC}"
$COMPOSE down --remove-orphans > /dev/null 2>&1 &
PID=$!
spinner $PID
wait $PID
echo -e "${GREEN}[OK]${NC}"

# Pull (On laisse l'affichage natif)
echo -e "${CYAN}→ $T_PULLING $NEW_TAG...${NC}"
$COMPOSE pull
if [ $? -ne 0 ]; then echo -e "${RED}[ERROR] Pull failed. Restoring .env...${NC}"; cp .env.bak .env; exit 1; fi

# ==============================================================================
# 5. RELANCE PROGRESSIVE (Logique Start.sh)
# ==============================================================================
echo -e "\n${BLUE}$T_START_PHASE1${NC}"
echo -ne "${CYAN}→ Starting containers...${NC}"

# Scale 0 pour monitoring
$COMPOSE up -d --remove-orphans --scale elasticsearch=0 --scale logstash=0 > /dev/null 2>&1 &
PID=$!
spinner $PID
wait $PID
if [ $? -ne 0 ]; then echo -e "${RED}[ERROR] Start failed.${NC}"; exit 1; fi
echo -e "${GREEN}[OK]${NC}"

# Health Check
echo -e "\n${BLUE}$T_START_PHASE2${NC}"
MAX_RETRIES=30
COUNT=0
SUCCESS=false

echo -ne "$T_WAIT_HTTP  ${YELLOW}0s${NC}"

while [ $COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "$LOGIN_URL")

    if [[ "$HTTP_CODE" == "200" ]]; then
        SUCCESS=true
        echo -e "\r$T_WAIT_HTTP  ${GREEN}[OK] ($((COUNT * 5))s)${NC}"
        break
    else
        sleep 5
        ((COUNT++))
        echo -ne "\r$T_WAIT_HTTP  ${YELLOW}$((COUNT * 5))s${NC}"
    fi
done

if [ "$SUCCESS" = false ]; then
    echo -e "\n${RED}[TIMEOUT] Update seems to have failed.${NC}"
    echo -e "Check logs: $COMPOSE logs -f app"
    exit 1
fi

# Activation Monitoring
echo -e "\n${BLUE}$T_START_PHASE3${NC}"
echo -ne "${CYAN}→ ElasticSearch & Logstash...${NC}"
$COMPOSE up -d elasticsearch logstash > /dev/null 2>&1 &
PID=$!
spinner $PID
wait $PID
echo -e "${GREEN}[OK]${NC}"

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   $T_SUCCESS ($NEW_TAG)      ${NC}"
echo -e "${GREEN}==============================================${NC}"