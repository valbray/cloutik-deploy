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

# ==============================================================================
# 0. DÉTECTION DE LA LANGUE
# ==============================================================================
# On vérifie si un argument est passé (ex: ./start.sh FR)
if [[ "$1" == "FR" ]]; then
    LAN_CHOICE="2"
elif [[ "$1" == "EN" ]]; then
    LAN_CHOICE="1"
else
    # Sinon, on demande
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${BLUE}   CLOUTIK LAUNCHER                           ${NC}"
    echo -e "${BLUE}==============================================${NC}"
    echo "  1) English"
    echo "  2) Français"
    read -p "Choice / Choix [1-2]: " LAN_CHOICE
fi

if [ "$LAN_CHOICE" == "2" ]; then
    # --- FRANÇAIS ---
    T_TITLE="LANCEMENT CLOUTIK (MODE VISUEL)"
    T_CHECKING="Vérification de l'environnement..."
    T_ERR_DOCKER="[ERREUR] Docker est requis."
    T_ERR_COMPOSE="[ERREUR] Docker Compose est requis."
    T_ERR_ENV="[ERREUR] Fichier .env manquant."

    T_PHASE1="[PHASE 1] Initialisation des services essentiels"
    T_PULL="→ Téléchargement des images (Pull)..."
    T_ERR_PULL="[ERREUR] Le téléchargement a échoué."
    T_START_CORE="→ Démarrage des conteneurs (App, DB, Nginx)..."
    T_ERR_START="[ERREUR] Le démarrage a échoué."

    T_PHASE2="[PHASE 2] Vérification de la disponibilité"
    T_TARGET="Cible :"
    T_WAIT="En attente de réponse HTTP 200..."
    T_TIMEOUT="[TIMEOUT] Le système ne répond pas."
    T_DIAG="Diagnostic :"

    T_PHASE3="[PHASE 3] Activation du monitoring"
    T_START_MONITOR="→ Démarrage ElasticSearch & Logstash..."

    T_SUCCESS="APPLICATION DÉMARRÉE AVEC SUCCÈS !"
    T_ACCESS="Accédez à votre application ici :"
else
    # --- ENGLISH ---
    T_TITLE="CLOUTIK LAUNCHER (VISUAL MODE)"
    T_CHECKING="Checking environment..."
    T_ERR_DOCKER="[ERROR] Docker is required."
    T_ERR_COMPOSE="[ERROR] Docker Compose is required."
    T_ERR_ENV="[ERROR] .env file is missing."

    T_PHASE1="[PHASE 1] Initializing Essential Services"
    T_PULL="→ Downloading images (Pull)..."
    T_ERR_PULL="[ERROR] Pull failed."
    T_START_CORE="→ Starting containers (App, DB, Nginx)..."
    T_ERR_START="[ERROR] Start failed."

    T_PHASE2="[PHASE 2] Health Check"
    T_TARGET="Target:"
    T_WAIT="Waiting for HTTP 200 response..."
    T_TIMEOUT="[TIMEOUT] System is not responding."
    T_DIAG="Diagnostic:"

    T_PHASE3="[PHASE 3] Enabling Monitoring"
    T_START_MONITOR="→ Starting ElasticSearch & Logstash..."

    T_SUCCESS="APPLICATION STARTED SUCCESSFULLY!"
    T_ACCESS="Access your application here:"
fi

# ==============================================================================
# 1. PRÉPARATION
# ==============================================================================
if [ -z "$1" ]; then clear; fi # On clear seulement si on est en mode interactif
echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   $T_TITLE ${NC}"
echo -e "${BLUE}==============================================${NC}"

# ... (Vérifications habituelles inchangées) ...
if ! command -v docker &> /dev/null; then echo -e "${RED}$T_ERR_DOCKER${NC}"; exit 1; fi
if docker compose version >/dev/null 2>&1; then COMPOSE="docker compose"; elif command -v docker-compose >/dev/null 2>&1; then COMPOSE="docker-compose"; else echo -e "${RED}$T_ERR_COMPOSE${NC}"; exit 1; fi
if [ ! -f .env ]; then echo -e "${RED}$T_ERR_ENV${NC}"; exit 1; fi

APP_URL=$(grep "^APP_URL=" .env | cut -d '=' -f2)
LOGIN_URL="${APP_URL}/login"

# ==============================================================================
# PHASE 1 : CŒUR DU SYSTÈME
# ==============================================================================
echo -e "\n${BLUE}$T_PHASE1${NC}"

# 1. TÉLÉCHARGEMENT
echo -e "${CYAN}$T_PULL${NC}"
$COMPOSE pull

if [ $? -ne 0 ]; then echo -e "${RED}$T_ERR_PULL${NC}"; exit 1; fi

# 2. DÉMARRAGE (Avec animation Spinner)
echo -ne "${CYAN}$T_START_CORE${NC}"

$COMPOSE up -d --remove-orphans --scale elasticsearch=0 --scale logstash=0 > /dev/null 2>&1 &
PID=$!

spinner $PID
wait $PID
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[ERROR]${NC}"
    exit 1
fi

mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache logs/laravel

sudo chown -R 33:33 storage bootstrap/cache logs/laravel 2>/dev/null || chown -R 33:33 storage bootstrap/cache logs/laravel
sudo chmod -R 775 storage bootstrap/cache logs/laravel 2>/dev/null || chmod -R 775 storage bootstrap/cache logs/laravel


# ==============================================================================
# PHASE 2 : VÉRIFICATION DE SANTÉ (COMPTEUR)
# ==============================================================================
echo -e "\n${BLUE}$T_PHASE2${NC}"
echo -e "$T_TARGET $LOGIN_URL"

MAX_RETRIES=30
COUNT=0
SUCCESS=false

echo -ne "$T_WAIT  ${YELLOW}0s${NC}"

while [ $COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "$LOGIN_URL")

    if [[ "$HTTP_CODE" == "200" ]]; then
        SUCCESS=true
        echo -e "\r$T_WAIT  ${GREEN}[OK] ($((COUNT * 5))s)${NC}"
        break
    else
        sleep 5
        ((COUNT++))
        echo -ne "\r$T_WAIT  ${YELLOW}$((COUNT * 5))s${NC}"
    fi
done

if [ "$SUCCESS" = false ]; then
    echo -e "\n\n${RED}$T_TIMEOUT${NC}"
    echo -e "$T_DIAG $COMPOSE logs app"
    exit 1
fi

# ==============================================================================
# PHASE 3 : SERVICES ADDITIONNELS
# ==============================================================================
echo -e "\n${BLUE}$T_PHASE3${NC}"
echo -ne "${CYAN}$T_START_MONITOR${NC}"

$COMPOSE up -d elasticsearch logstash > /dev/null 2>&1 &
PID=$!
spinner $PID
wait $PID

echo -e "${GREEN}[OK]${NC}"

mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache logs/laravel

sudo chown -R 33:33 storage bootstrap/cache logs/laravel 2>/dev/null || chown -R 33:33 storage bootstrap/cache logs/laravel
sudo chmod -R 775 storage bootstrap/cache logs/laravel 2>/dev/null || chmod -R 775 storage bootstrap/cache logs/laravel



echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   $T_SUCCESS             ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "$T_ACCESS $APP_URL"