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
echo -e "${BLUE}   LANCEMENT CLOUTIK (VISUAL MODE)            ${NC}"
echo -e "${BLUE}==============================================${NC}"

# ==============================================================================
# 1. DÉTECTION ENVIRONNEMENT
# ==============================================================================
# ... (Vérifications habituelles inchangées) ...
if ! command -v docker &> /dev/null; then echo -e "${RED}[ERREUR] Docker requis.${NC}"; exit 1; fi
if docker compose version >/dev/null 2>&1; then COMPOSE="docker compose"; elif command -v docker-compose >/dev/null 2>&1; then COMPOSE="docker-compose"; else echo -e "${RED}[ERREUR] Docker Compose requis.${NC}"; exit 1; fi
if [ ! -f .env ]; then echo -e "${RED}[ERREUR] Fichier .env manquant.${NC}"; exit 1; fi

APP_URL=$(grep "^APP_URL=" .env | cut -d '=' -f2)
LOGIN_URL="${APP_URL}/login"

# ==============================================================================
# PHASE 1 : CŒUR DU SYSTÈME
# ==============================================================================
echo -e "\n${BLUE}[PHASE 1] Initialisation des services essentiels${NC}"

# 1. TÉLÉCHARGEMENT (On laisse l'affichage natif de Docker car il est top)
echo -e "${CYAN}→ Téléchargement des images (Pull)...${NC}"
$COMPOSE pull

if [ $? -ne 0 ]; then echo -e "${RED}[ERREUR] Pull échoué.${NC}"; exit 1; fi

# 2. DÉMARRAGE (Avec animation Spinner)
echo -ne "${CYAN}→ Démarrage des conteneurs (App, DB, Nginx)...${NC}"

# On lance la commande en arrière-plan (&) et on récupère son PID ($!)
$COMPOSE up -d --remove-orphans --scale elasticsearch=0 --scale logstash=0 > /dev/null 2>&1 &
PID=$!

# On lance l'animation pendant que la commande tourne
spinner $PID
wait $PID # On attend la fin réelle pour récupérer le code de retour
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[ERREUR]${NC}"
    exit 1
fi

# ==============================================================================
# PHASE 2 : VÉRIFICATION DE SANTÉ (COMPTEUR)
# ==============================================================================
echo -e "\n${BLUE}[PHASE 2] Vérification de la disponibilité${NC}"
echo -e "Cible : $LOGIN_URL"

MAX_RETRIES=30
COUNT=0
SUCCESS=false

# On affiche un compteur qui s'incrémente sur la même ligne
echo -ne "En attente de réponse HTTP 200...  ${YELLOW}0s${NC}"

while [ $COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "$LOGIN_URL")

    if [[ "$HTTP_CODE" == "200" ]]; then
        SUCCESS=true
        # On efface le compteur et on met OK
        echo -e "\rEn attente de réponse HTTP 200...  ${GREEN}[OK] (Réponse en $((COUNT * 5))s)${NC}"
        break
    else
        sleep 5
        ((COUNT++))
        # Mise à jour du compteur sur la même ligne (\r)
        echo -ne "\rEn attente de réponse HTTP 200...  ${YELLOW}$((COUNT * 5))s${NC}"
    fi
done

if [ "$SUCCESS" = false ]; then
    echo -e "\n\n${RED}[TIMEOUT] Le système ne répond pas.${NC}"
    echo -e "Diagnostic : $COMPOSE logs app"
    exit 1
fi

# ==============================================================================
# PHASE 3 : SERVICES ADDITIONNELS
# ==============================================================================
echo -e "\n${BLUE}[PHASE 3] Activation du monitoring${NC}"
echo -ne "${CYAN}→ Démarrage ElasticSearch & Logstash...${NC}"

$COMPOSE up -d elasticsearch logstash > /dev/null 2>&1 &
PID=$!
spinner $PID
wait $PID

echo -e "${GREEN}[OK]${NC}"

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   INSTALLATION TERMINÉE !                    ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "Accédez à votre application ici : $APP_URL"