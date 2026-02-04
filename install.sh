#!/bin/bash

# ==============================================================================
# CONFIGURATION GLOBALE
# ==============================================================================
MASTER_API_URL="https://api.master-prep.cloutik.app"

# --- COULEURS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ==============================================================================
# CHOIX DE LA LANGUE ET TRADUCTIONS
# ==============================================================================
clear
echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}          CLOUTIK INSTALLATION WIZARD               ${NC}"
echo -e "${BLUE}====================================================${NC}"
echo "  1) English"
echo "  2) Français"
echo -e "${BLUE}====================================================${NC}"
read -p "Choice / Choix [1-2]: " LAN_CHOICE

# --- Dictionnaire de langue ---
if [ "$LAN_CHOICE" == "2" ]; then
    # --- FRANÇAIS ---
    L="FR"
    
    # Docker
    T_DOCKER_CHECK="[1/4] Vérification de Docker..."
    T_DOCKER_MISSING="Docker n'est pas installé. Installation automatique..."
    T_DOCKER_ERR="L'installation de Docker a échoué."
    T_DOCKER_OK="Docker est prêt."

    # JQ
    T_JQ_MISSING="[!] 'jq' n'est pas installé."
    T_JQ_PROMPT="Voulez-vous installer 'jq' maintenant ? (Sudo requis) [y/N] : "
    T_JQ_OS_ERR="Système non supporté automatiquement pour JQ."
    
    # Base
    T_BASE_CONFIG="[2/4] CONFIGURATION DE BASE"
    T_DOMAIN_P="Nom de domaine (ex: cloutik.domaine.com)"
    T_EMAIL_P="Email de facturation"
    T_COMPANY_P="Nom de l'entreprise"
    T_PASS_P="Mot de passe SuperAdmin"

    # DNS
    T_DNS_TITLE="--- VÉRIFICATION DNS ---"
    T_DNS_IP="Votre IP Publique détectée :"
    T_DNS_RESOLVE_ERR="Résolution impossible"
    T_DNS_IP_ERR="Pointe vers une autre IP"
    T_DNS_WARN="[ATTENTION] La configuration DNS semble incorrecte."
    T_DNS_CONT="Voulez-vous continuer quand même ? (o/N) : "

    # Steps API
    T_STEP1_INFO="[3/4] RÉCUPÉRATION DES ACCÈS"
    T_STEP1_DESC="Connexion au Master pour générer vos jetons..."
    T_TOKEN_VALID="--- VALIDATION DES ACCÈS ---"
    T_MAIL_SENT="Un e-mail a été envoyé à :"
    T_ALREADY_SENT="[INFO] Demande existante (Code 409). Vérifiez vos e-mails."
    T_TOKEN_DESC="Saisissez les informations reçues :"
    T_PARTNER_L="Partner Token"
    T_REG_USER_L="Registry User"
    T_REG_PASS_L="Registry Password"

    T_STEP2_INFO="--- ENREGISTREMENT DE L'INSTANCE ---"
    T_STEP2_EXIST="[ERREUR] Cette instance existe déjà (Code 409)."

    # Captcha & VPN
    T_CAPTCHA_TITLE="--- SÉCURITÉ RECAPTCHA (GOOGLE) ---"
    T_CAPTCHA_ASK="Voulez-vous activer la protection reCAPTCHA v3 ? (o/N) : "
    T_CAPTCHA_TUTO="1. Allez sur : https://www.google.com/recaptcha/admin/create\n2. Créez une clé de type 'reCAPTCHA v3'\n3. Ajoutez votre domaine : "
    T_CAPTCHA_SITE="Clé du site (Site Key)"
    T_CAPTCHA_SECRET="Clé secrète (Secret Key)"
    T_VPN_TITLE="--- CONFIGURATION VPN ---"

    # Final
    T_FINAL_STEP="[4/4] FINALISATION"
    T_SUCCESS="FÉLICITATIONS ! Configuration terminée."
    T_ENV_LOAD="Configuration existante détectée."
    T_START_PROMPT="Voulez-vous démarrer l'application maintenant ? [Y/n] "
    T_START_NOW="Lancement immédiat via start.sh..."
    T_START_LATER="Démarrage ignoré. Lancez plus tard via : ./start.sh"
    T_START_MISSING="[ERREUR] Le script start.sh est introuvable."

else
    # --- ENGLISH ---
    L="EN"

    # Docker
    T_DOCKER_CHECK="[1/4] Checking Docker..."
    T_DOCKER_MISSING="Docker is not installed. Installing automatically..."
    T_DOCKER_ERR="Docker installation failed."
    T_DOCKER_OK="Docker is ready."

    # JQ
    T_JQ_MISSING="[!] 'jq' is not installed."
    T_JQ_PROMPT="Install 'jq' now? (Sudo required) [y/N] : "
    T_JQ_OS_ERR="OS not supported for JQ auto-install."

    # Base
    T_BASE_CONFIG="[2/4] BASE CONFIGURATION"
    T_DOMAIN_P="Domain Name (e.g., cloutik.domaine.com)"
    T_EMAIL_P="Billing Email"
    T_COMPANY_P="Company Name"
    T_PASS_P="SuperAdmin Password"

    # DNS
    T_DNS_TITLE="--- DNS VERIFICATION ---"
    T_DNS_IP="Your detected Public IP:"
    T_DNS_RESOLVE_ERR="Resolution failed"
    T_DNS_IP_ERR="Points to wrong IP"
    T_DNS_WARN="[WARNING] DNS configuration seems incorrect."
    T_DNS_CONT="Do you want to continue anyway? (y/N) : "

    # Steps API
    T_STEP1_INFO="[3/4] ACCESS RETRIEVAL"
    T_STEP1_DESC="Connecting to Master..."
    T_TOKEN_VALID="--- ACCESS VALIDATION ---"
    T_MAIL_SENT="Email sent to:"
    T_ALREADY_SENT="[INFO] Request exists (Code 409). Check your email."
    T_TOKEN_DESC="Enter received information:"
    T_PARTNER_L="Partner Token"
    T_REG_USER_L="Registry User"
    T_REG_PASS_L="Registry Password"

    T_STEP2_INFO="--- INSTANCE REGISTRATION ---"
    T_STEP2_EXIST="[ERROR] Instance already exists (Code 409)."

    # Captcha & VPN
    T_CAPTCHA_TITLE="--- RECAPTCHA SECURITY (GOOGLE) ---"
    T_CAPTCHA_ASK="Do you want to enable reCAPTCHA v3 protection? (y/N) : "
    T_CAPTCHA_TUTO="1. Go to: https://www.google.com/recaptcha/admin/create\n2. Create a key type 'reCAPTCHA v3'\n3. Add your domain: "
    T_CAPTCHA_SITE="Site Key"
    T_CAPTCHA_SECRET="Secret Key"
    T_VPN_TITLE="--- VPN CONFIGURATION ---"

    # Final
    T_FINAL_STEP="[4/4] FINALIZATION"
    T_SUCCESS="CONGRATULATIONS! Configuration complete."
    T_ENV_LOAD="Existing configuration detected."
    T_START_PROMPT="Do you want to start the application now? [Y/n] "
    T_START_NOW="Starting immediately via start.sh..."
    T_START_LATER="Skipped. You can start later using: ./start.sh"
    T_START_MISSING="[ERROR] start.sh script not found."
fi

# ==============================================================================
# 1. VERIFICATIONS SYSTÈME (DOCKER & JQ)
# ==============================================================================
echo -e "\n${BLUE}$T_DOCKER_CHECK${NC}"

# --- Check Docker ---
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}$T_DOCKER_MISSING${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}$T_DOCKER_ERR${NC}"; exit 1
    fi
    # Add current user to docker group (avoid sudo for docker)
    # sudo usermod -aG docker $USER
else
    echo -e "${GREEN}[OK] Docker${NC}"
fi

# --- Check JQ ---
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}$T_JQ_MISSING${NC}"
    [ -f /etc/os-release ] && . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        read -p "$T_JQ_PROMPT" INSTALL_JQ
        [[ "$INSTALL_JQ" =~ ^[yY]$ ]] && sudo apt-get update && sudo apt-get install -y jq || exit 1
    else
        echo -e "${RED}$T_JQ_OS_ERR${NC}"; exit 1
    fi
else
    echo -e "${GREEN}[OK] JQ${NC}"
fi

# ==============================================================================
# 2. PRÉPARATION ET CHARGEMENT ANCIEN .ENV
# ==============================================================================
echo -e "\n${GREEN}$T_BASE_CONFIG${NC}"

if [ -f .env ]; then
    echo -e "${CYAN}$T_ENV_LOAD${NC}"
    OLD_DOMAIN=$(grep "^ROUTE_DOMAIN=" .env | cut -d '=' -f2)
    OLD_EMAIL=$(grep "^EMAIL_SA=" .env | cut -d '=' -f2)
    OLD_COMPANY=$(grep "^LAST_NAME_SA=" .env | cut -d '=' -f2)
    OLD_SA_PASS=$(grep "^PASSWORD_SA=" .env | cut -d '=' -f2)
    OLD_DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2)
    OLD_ELASTIC_PASS=$(grep "^ELASTICSEARCH_PASS=" .env | cut -d '=' -f2)
    OLD_MASTER_TOKEN=$(grep "^master_token=" .env | cut -d '=' -f2)

    OLD_VPN_IP=$(grep "^VPN_SERVER_IP=" .env | cut -d '=' -f2)
    OLD_VPN_NET=$(grep "^VPN_NETWORK=" .env | cut -d '=' -f2)
    OLD_VPN_MASK=$(grep "^VPN_NETMASK=" .env | cut -d '=' -f2)
    OLD_VPN_PREF=$(grep "^VPN_NETMASK_PREFIX=" .env | cut -d '=' -f2)
    OLD_VPN_PORT=$(grep "^VPN_PORT=" .env | cut -d '=' -f2)
    OLD_CAPTCHA_SITE=$(grep "^VITE_CAPTCHA_SITE_KEY=" .env | cut -d '=' -f2)
    OLD_CAPTCHA_SECRET=$(grep "^CAPTCHA_SECRET_KEY=" .env | cut -d '=' -f2)
    OLD_REG_USER=$(grep "^REGISTRY_USER=" .env | cut -d '=' -f2)
fi

DB_PASSWORD=${OLD_DB_PASS:-$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 13)}
ELASTIC_PASS=${OLD_ELASTIC_PASS:-$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 10)}

# --- SAISIE ET NETTOYAGE DU DOMAINE ---
read -p "$T_DOMAIN_P [${OLD_DOMAIN}] : " INPUT_DOMAIN
DOMAIN_NAME=${INPUT_DOMAIN:-$OLD_DOMAIN}
RAW_DOMAIN=$(echo "$DOMAIN_NAME" | sed -E 's~^https?://~~')

read -p "$T_EMAIL_P [${OLD_EMAIL}] : " B_EMAIL; B_EMAIL=${B_EMAIL:-$OLD_EMAIL}
read -p "$T_COMPANY_P [${OLD_COMPANY}] : " B_COMPANY; B_COMPANY=${B_COMPANY:-$OLD_COMPANY}
read -p "$T_PASS_P [${OLD_SA_PASS}] : " B_SA_PASS; B_SA_PASS=${B_SA_PASS:-$OLD_SA_PASS}

# ==============================================================================
# 3. TEST DNS (BOUCLE DE VÉRIFICATION)
# ==============================================================================
echo -e "\n${GREEN}$T_DNS_TITLE${NC}"
PUBLIC_IP=$(curl -s https://api.ipify.org || echo "127.0.0.1")
echo -e "$T_DNS_IP ${BLUE}$PUBLIC_IP${NC}"

DOMAINS_TO_CHECK=("$RAW_DOMAIN" "api.$RAW_DOMAIN" "api-interf.$RAW_DOMAIN" "api-admin.$RAW_DOMAIN" "webfig.$RAW_DOMAIN" "vpn.$RAW_DOMAIN" )

while true; do
    DNS_ERROR=false
    echo -e "\n--- Checking DNS Records ---"

    for d in "${DOMAINS_TO_CHECK[@]}"; do
        # On tente de résoudre le domaine
        RESOLVED_IP=$(getent hosts "$d" | awk '{ print $1 }' | head -n 1)

        if [ -z "$RESOLVED_IP" ]; then
            echo -e "  [${RED}KO${NC}] $d : $T_DNS_RESOLVE_ERR"
            DNS_ERROR=true
        elif [ "$RESOLVED_IP" != "$PUBLIC_IP" ]; then
            echo -e "  [${YELLOW}WARN${NC}] $d : $RESOLVED_IP ($T_DNS_IP_ERR: $PUBLIC_IP)"
            DNS_ERROR=true
        else
            echo -e "  [${GREEN}OK${NC}] $d : $RESOLVED_IP"
        fi
    done

    # Si tout est OK, on sort de la boucle automatiquement
    if [ "$DNS_ERROR" = false ]; then
        echo -e "${GREEN}[OK] DNS Validated.${NC}"
        break
    fi

    # Sinon, on affiche le menu d'erreur
    echo -e "\n${RED}$T_DNS_WARN${NC}"
    
    if [ "$L" == "FR" ]; then
        echo "  1) Réessayer la vérification (après mise à jour DNS)"
        echo "  2) Continuer quand même (Forcer)"
        echo "  3) Quitter l'installation"
        read -p "  Votre choix [1-3] : " DNS_ACTION
    else
        echo "  1) Retry verification (after DNS update)"
        echo "  2) Continue anyway (Force)"
        echo "  3) Quit installation"
        read -p "  Choice [1-3] : " DNS_ACTION
    fi

    case $DNS_ACTION in
        1)
            echo -e "${YELLOW}Mise à jour... (Patientez quelques secondes)${NC}"
            sleep 2
            continue # Relance la boucle while
            ;;
        2)
            echo -e "${YELLOW}Force Continue...${NC}"
            break # Sort de la boucle et continue le script
            ;;
        *)
            echo "STOP."
            exit 1
            ;;
    esac
done

# ==============================================================================
# 4. ÉTAPE 1 : OBTENTION DES TOKENS
# ==============================================================================
echo -e "\n${BLUE}$T_STEP1_INFO${NC}"
echo -e "$T_STEP1_DESC"

TOKEN_OUT=$(curl -s -w "\n%{http_code}" --location "${MASTER_API_URL}/api/installation/request-token" \
--header "Accept: application/json" \
--form "email=$B_EMAIL" \
--form "company=$B_COMPANY")

TOKEN_RES=$(echo "$TOKEN_OUT" | head -n -1)
TOKEN_HTTP=$(echo "$TOKEN_OUT" | tail -n 1)

if [[ "$TOKEN_HTTP" =~ ^20[0-1]$ ]]; then
    AUTO_PARTNER=$(echo "$TOKEN_RES" | jq -r '.data.partner_token // empty')
    AUTO_REG_USER=$(echo "$TOKEN_RES" | jq -r '.data.registry_user // "robot$cloutik+prod-deploy"')
    AUTO_REG_PASS=$(echo "$TOKEN_RES" | jq -r '.data.registry_token // empty')

    echo -e "\n${GREEN}$T_TOKEN_VALID${NC}"
    echo -e "$T_MAIL_SENT ${YELLOW}$B_EMAIL${NC}"

elif [[ "$TOKEN_HTTP" == "409" ]]; then
    echo -e "\n${YELLOW}$T_ALREADY_SENT${NC}"
    AUTO_PARTNER=""
    AUTO_REG_USER="robot\$cloutik+prod-deploy"
    AUTO_REG_PASS=""

else
    echo -e "${RED}[ERROR] Step 1 failed (HTTP $TOKEN_HTTP).${NC}"
    echo "$TOKEN_RES" | jq '.'
    exit 1
fi

# ==============================================================================
# VALIDATION MANUELLE
# ==============================================================================
echo -e "$T_TOKEN_DESC"

# 1. Partner Token
read -p "$T_PARTNER_L [${AUTO_PARTNER}] : " PARTNER_TOKEN
PARTNER_TOKEN=${PARTNER_TOKEN:-$AUTO_PARTNER}
while [[ -z "$PARTNER_TOKEN" ]]; do
    echo -e "${RED}Token required / Requis${NC}"
    read -p "$T_PARTNER_L : " PARTNER_TOKEN
done

# 2. Registry User
read -p "$T_REG_USER_L [${AUTO_REG_USER:-$OLD_REG_USER}] : " REGISTRY_USER
REGISTRY_USER=${REGISTRY_USER:-${AUTO_REG_USER:-$OLD_REG_USER}}

# 3. Registry Token (Masqué)
echo -n "$T_REG_PASS_L : "
read -s REGISTRY_TOKEN
echo ""
REGISTRY_TOKEN=${REGISTRY_TOKEN:-$AUTO_REG_PASS}
while [[ -z "$REGISTRY_TOKEN" ]]; do
    echo -e "${RED}Token required / Requis${NC}"
    echo -n "$T_REG_PASS_L : "
    read -s REGISTRY_TOKEN
    echo ""
done

# ==============================================================================
# 5. ÉTAPE 2 : REGISTER (AVEC PARTNER TOKEN)
# ==============================================================================
echo -e "\n${BLUE}$T_STEP2_INFO${NC}"

REG_OUT=$(curl -s -w "\n%{http_code}" --location "${MASTER_API_URL}/api/instances/register" \
--header "Accept: application/json" \
--header "Authorization: Bearer ${PARTNER_TOKEN}" \
--form "billing_email=$B_EMAIL" \
--form "company=$B_COMPANY" \
--form "app_url=${RAW_DOMAIN}")

REG_RES=$(echo "$REG_OUT" | head -n -1)
REG_HTTP=$(echo "$REG_OUT" | tail -n 1)

MASTER_TOKEN=$(echo "$REG_RES" | jq -r '.data.master_token // empty')

if [[ "$REG_HTTP" =~ ^20[0-1]$ ]]; then
    echo -e "${GREEN}[OK] Success.${NC}"

elif [[ "$REG_HTTP" == "409" ]]; then
    SERVER_MSG=$(echo "$REG_RES" | jq -r '.message // "Unknown Error"')
    echo -e "${YELLOW}$T_STEP2_EXIST${NC}"
    echo -e "${YELLOW}$SERVER_MSG${NC}"

    if [ -n "$OLD_MASTER_TOKEN" ]; then
        echo -e "${GREEN}[INFO] Using existing master_token from .env${NC}"
        MASTER_TOKEN=$OLD_MASTER_TOKEN
    else
        echo -e "${RED}[STOP] No master_token available. Exiting.${NC}"
        exit 1
    fi
else
    echo -e "${RED}[ERROR] Step 2 failed (HTTP $REG_HTTP).${NC}"
    echo "$REG_RES" | jq '.'
    exit 1
fi

# ==============================================================================
# 6. SÉCURITÉ RECAPTCHA & VPN
# ==============================================================================
echo -e "\n${BLUE}$T_CAPTCHA_TITLE${NC}"
read -p "$T_CAPTCHA_ASK" ENABLE_CAPTCHA

if [[ "$ENABLE_CAPTCHA" =~ ^[oOeyY]$ ]]; then
    echo -e "${YELLOW}$T_CAPTCHA_TUTO $RAW_DOMAIN ${NC}"
    echo ""
    read -p "$T_CAPTCHA_SITE [${OLD_CAPTCHA_SITE}] : " IN_CAPTCHA_SITE
    CAPTCHA_SITE_KEY=${IN_CAPTCHA_SITE:-$OLD_CAPTCHA_SITE}
    read -p "$T_CAPTCHA_SECRET [${OLD_CAPTCHA_SECRET}] : " IN_CAPTCHA_SECRET
    CAPTCHA_SECRET_KEY=${IN_CAPTCHA_SECRET:-$OLD_CAPTCHA_SECRET}
else
    CAPTCHA_SITE_KEY=$OLD_CAPTCHA_SITE
    CAPTCHA_SECRET_KEY=$OLD_CAPTCHA_SECRET
fi

echo -e "\n${YELLOW}$T_VPN_TITLE${NC}"
read -p "VPN Gateway IP [${OLD_VPN_IP:-10.16.0.1}] : " V_IP; VPN_SERVER_IP=${V_IP:-${OLD_VPN_IP:-10.16.0.1}}
read -p "VPN Network [${OLD_VPN_NET:-10.16.0.0}] : " V_NET; VPN_NETWORK=${V_NET:-${OLD_VPN_NET:-10.16.0.0}}
read -p "VPN Mask [${OLD_VPN_MASK:-255.255.0.0}] : " V_MASK; VPN_NETMASK=${V_MASK:-${OLD_VPN_MASK:-255.255.0.0}}
read -p "VPN Prefix [${OLD_VPN_PREF:-16}] : " V_PREF; VPN_NETMASK_PREFIX=${V_PREF:-${OLD_VPN_PREF:-16}}
read -p "VPN Port [${OLD_VPN_PORT:-1194}] : " V_PORT; VPN_PORT=${V_PORT:-${OLD_VPN_PORT:-1194}}

# ==============================================================================
# 7. GÉNÉRATION .ENV (STRUCTURE COMPLÈTE)
# ==============================================================================
echo -e "\n${BLUE}$T_FINAL_STEP${NC}"
echo -e "Generating .env..."

cat > .env <<EOF
# =====================================================
# APPLICATION LARAVEL
# =====================================================
APP_NAME=cloutik
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://${RAW_DOMAIN}
DOCKER_MODE=true
TRUST_PROXIES=true
RUN_MIGRATIONS=true
RUN_SEED=true
RUN_NPM_BUILD=true
TELESCOPE_PATH=admin/monitoring
TELESCOPE_ENABLED=false

# =====================================================
# VAULT CONFIGURATION
# =====================================================
VAULT_ADDR=http://vault:8200
VAULT_TOKEN=root
VAULT_TOKEN_FILE=/vault/tokens/.tokens/cloutik_token

# =====================================================
# ROUTES & SUBDOMAINS
# =====================================================
ROUTE_DOMAIN=${RAW_DOMAIN}
ROUTE_API_INTERF_SUBDOMAIN=api-interf.${RAW_DOMAIN}
ROUTE_API_ADMIN_SUBDOMAIN=api-admin.${RAW_DOMAIN}
ROUTE_API_SUBDOMAIN=api.${RAW_DOMAIN}

# =====================================================
# DATABASE
# =====================================================
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=cloutik
DB_USERNAME=cloutik
DB_PASSWORD=${DB_PASSWORD}
MYSQL_ROOT_PASSWORD=${DB_PASSWORD}

# =====================================================
# SUPERADMIN
# =====================================================
FIRST_NAME_SA=superadmin
TIMEZONE_SA=Europe/Paris
LAST_NAME_SA=${B_COMPANY}
EMAIL_SA=${B_EMAIL}
PASSWORD_SA=${B_SA_PASS}

# =====================================================
# SECURITY - reCAPTCHA
# =====================================================
VITE_CAPTCHA_SITE_KEY=${CAPTCHA_SITE_KEY}
CAPTCHA_SECRET_KEY=${CAPTCHA_SECRET_KEY}

# =====================================================
# ELASTIC & LOGSTASH
# =====================================================
ELASTICSEARCH_HOST=elasticsearch
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_USER=elastic
ELASTICSEARCH_INDEX=mikrotik-*
ELASTICSEARCH_PASS=${ELASTIC_PASS}
LOGSTASH_IP=${PUBLIC_IP}
LOGSTASH_PORT=5014

# =====================================================
# MASTER & REGISTRY
# =====================================================
MASTER_API_URL=${MASTER_API_URL}
master_token=${MASTER_TOKEN}

# =====================================================
# VPN CONFIGURATION
# =====================================================
VPN_SERVER_IP=${VPN_SERVER_IP}
VPN_NETWORK=${VPN_NETWORK}
VPN_NETMASK=${VPN_NETMASK}
VPN_NETMASK_PREFIX=${VPN_NETMASK_PREFIX}
VPN_PORT=${VPN_PORT}
VPN_PROTO=tcp-server
VAULT_TOKEN=cloutik_token
GATEWAY_SHARED_TOKEN=test
VPN_CLIENT_TO_CLIENT=true

# =====================================================
# RADIUS
# =====================================================
RADIUS_SECRET=testing123
RADIUS_DEBUG=false

# =====================================================
# OTHERS
# =====================================================
MONITORING_ALERT==false
QUEUE_CONNECTION=database
CACHE_DRIVER=file
SESSION_DRIVER=database
SESSION_LIFETIME=120
FTP_PASSIVEPORTS="30000-30599"
FTP_BASE_DIRECTORY=/var/www/html/cloutik
TAG=1.0
EOF

# =====================================================
# 8. PERMISSIONS & LOGIN FINAL
# =====================================================
mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
sudo chown -R 33:33 storage bootstrap/cache &> /dev/null
sudo chmod -R 775 storage bootstrap/cache &> /dev/null

echo -e "\n${BLUE}Final Docker Login Check...${NC}"
echo "$REGISTRY_TOKEN" | docker login registry.cloutik.app -u "$REGISTRY_USER" --password-stdin &> /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Registry Access Confirmed.${NC}"
else
    echo -e "${RED}[WARN] Registry login failed. Please check tokens in .env manually.${NC}"
fi

echo -e "\n${GREEN}$T_SUCCESS${NC}"

# =====================================================
# 9. PROPOSITION DE DÉMARRAGE
# =====================================================
if [ -f "start.sh" ]; then
    chmod +x start.sh
    echo ""
    read -p "$T_START_PROMPT" confirm_start
    confirm_start=${confirm_start:-Y} # Default Y

    if [[ "$confirm_start" =~ ^[yY] ]]; then
        echo -e "${YELLOW}$T_START_NOW${NC}"
        echo -e "----------------------------------------------"
        ./start.sh
    else
        echo -e "\n${YELLOW}$T_START_LATER${NC}"
    fi
else
    echo -e "${RED}$T_START_MISSING${NC}"
fi