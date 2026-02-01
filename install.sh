#!/bin/bash

# ==============================================================================
# CONFIGURATION GLOBALE
# ==============================================================================
MASTER_API_URL="https://api.master-prep.cloutik.app"
REGISTRY_USER="robot\$cloutik+prod-deploy"

# --- COULEURS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ==============================================================================
# CHOIX DE LA LANGUE
# ==============================================================================
clear
echo -e "${BLUE}==============================================${NC}"
echo "  Select your language / Choisissez votre langue"
echo "  1) English"
echo "  2) Français"
echo -e "${BLUE}==============================================${NC}"
read -p "Choice [1-2]: " LAN_CHOICE

if [ "$LAN_CHOICE" == "2" ]; then
    L="FR"; T_TITLE="CONFIGURATION CLOUTIK";
    T_ENV_DETECT="Configuration existante chargée (.env).";
    T_API_SEND="Inscription de l'instance sur le Master...";
    T_API_SUCCESS="Instance enregistrée avec succès !";
    T_API_FAIL="L'enregistrement Master a échoué.";
    T_VPN_Q="--- CONFIGURATION RÉSEAU VPN ---";
    T_DNS_TITLE="--- VÉRIFICATION DNS ---";
    T_DNS_IP="Votre IP Publique détectée :";
    T_DNS_WARN="ATTENTION : Certains sous-domaines ne sont pas configurés !";
    T_CONT="Voulez-vous continuer quand même ?";
    # --- AJOUT TRADUCTION CAPTCHA ---
    T_CAPTCHA_TITLE="--- SÉCURITÉ RECAPTCHA ---";
    T_CAPTCHA_SITE="Clé du site (Site Key)";
    T_CAPTCHA_SECRET="Clé secrète (Secret Key)";
else
    L="EN"; T_TITLE="CLOUTIK CONFIGURATION";
    T_ENV_DETECT="Existing configuration loaded (.env).";
    T_API_SEND="Registering instance on Master...";
    T_API_SUCCESS="Instance registered successfully!";
    T_API_FAIL="Master registration failed.";
    T_VPN_Q="--- VPN NETWORK CONFIGURATION ---";
    T_DNS_TITLE="--- DNS VERIFICATION ---";
    T_DNS_IP="Your detected Public IP:";
    T_DNS_WARN="WARNING: Some subdomains are not configured!";
    T_CONT="Do you want to continue anyway?";
    # --- AJOUT TRADUCTION CAPTCHA ---
    T_CAPTCHA_TITLE="--- RECAPTCHA SECURITY ---";
    T_CAPTCHA_SITE="Site Key";
    T_CAPTCHA_SECRET="Secret Key";
fi

# ==============================================================================
# 1. CHARGEMENT CONFIG EXISTANTE
# ==============================================================================
IS_UPDATE=false
if [ -f .env ]; then
    echo -e "${YELLOW}$T_ENV_DETECT${NC}"
    IS_UPDATE=true
    OLD_DOMAIN=$(grep "^ROUTE_DOMAIN=" .env | cut -d '=' -f2)
    OLD_DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2)
    OLD_ELASTIC_PASS=$(grep "^ELASTICSEARCH_PASS=" .env | cut -d '=' -f2)
    OLD_REGISTRY_TOKEN=$(grep "^REGISTRY_TOKEN=" .env | cut -d '=' -f2)
    OLD_SA_EMAIL=$(grep "^EMAIL_SA=" .env | cut -d '=' -f2)
    OLD_SA_LAST=$(grep "^LAST_NAME_SA=" .env | cut -d '=' -f2)
    OLD_SA_PASS=$(grep "^PASSWORD_SA=" .env | cut -d '=' -f2)
    OLD_MASTER_TOKEN=$(grep "^master_token=" .env | cut -d '=' -f2)
    OLD_APP_KEY=$(grep "^APP_KEY=" .env | cut -d '=' -f2)
    OLD_VPN_IP=$(grep "^VPN_SERVER_IP=" .env | cut -d '=' -f2)
    OLD_VPN_NET=$(grep "^VPN_NETWORK=" .env | cut -d '=' -f2)
    OLD_VPN_MASK=$(grep "^VPN_NETMASK=" .env | cut -d '=' -f2)
    OLD_VPN_PREF=$(grep "^VPN_NETMASK_PREFIX=" .env | cut -d '=' -f2)
    OLD_VPN_PORT=$(grep "^VPN_PORT=" .env | cut -d '=' -f2)
    
    # --- AJOUT RECUPERATION ANCIENNES CLES ---
    OLD_CAPTCHA_SITE=$(grep "^VITE_CAPTCHA_SITE_KEY=" .env | cut -d '=' -f2)
    OLD_CAPTCHA_SECRET=$(grep "^CAPTCHA_SECRET_KEY=" .env | cut -d '=' -f2)
fi

DB_PASSWORD=${OLD_DB_PASS:-$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 13)}
ELASTIC_PASS=${OLD_ELASTIC_PASS:-$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 10)}
APP_KEY=${OLD_APP_KEY:-""}

# ==============================================================================
# 2. INTERACTION UTILISATEUR
# ==============================================================================
echo -e "\n${GREEN}--- AUTHENTIFICATION ---${NC}"
read -sp "Registry Token : " INPUT_REGISTRY; echo ""
REGISTRY_TOKEN=${INPUT_REGISTRY:-$OLD_REGISTRY_TOKEN}

echo -e "${BLUE}Vérification de la connexion au registre...${NC}"

# Tentative de login Docker pour valider le token immédiatement
echo "$REGISTRY_TOKEN" | docker login registry.cloutik.app -u "$REGISTRY_USER" --password-stdin &> /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Connexion au registre réussie.${NC}"
else
    echo -e "${RED}[ERREUR] Token de registre invalide ou impossible de contacter registry.cloutik.app${NC}"
    read -p "Voulez-vous ignorer et continuer ? (y/N) : " FORCE_REG
    [[ ! "$FORCE_REG" =~ ^[yY]$ ]] && exit 1
fi


read -sp "Partner Authorization Token (Master API) : " PARTNER_TOKEN; echo ""

echo -e "\n${GREEN}--- DOMAINE ---${NC}"
read -p "Full Domain Name [${OLD_DOMAIN}] : " INPUT_DOM
DOMAIN_NAME=${INPUT_DOM:-$OLD_DOMAIN}
[[ -z "$DOMAIN_NAME" ]] && { echo -e "${RED}Error: Domain required.${NC}"; exit 1; }

# ==============================================================================
# 3. TEST DNS
# ==============================================================================
echo -e "\n${GREEN}$T_DNS_TITLE${NC}"
PUBLIC_IP=$(curl -s https://api.ipify.org || echo "127.0.0.1")
echo -e "$T_DNS_IP ${BLUE}$PUBLIC_IP${NC}"

DNS_ERROR=false
DOMAINS_TO_CHECK=("$DOMAIN_NAME" "api.$DOMAIN_NAME" "api-interf.$DOMAIN_NAME" "api-admin.$DOMAIN_NAME")

for d in "${DOMAINS_TO_CHECK[@]}"; do
    RESOLVED_IP=$(getent hosts "$d" | awk '{ print $1 }' | head -n 1)
    if [ -z "$RESOLVED_IP" ]; then
        echo -e "  [${RED}KO${NC}] $d : Résolution impossible"
        DNS_ERROR=true
    elif [ "$RESOLVED_IP" != "$PUBLIC_IP" ]; then
        echo -e "  [${YELLOW}WARN${NC}] $d : Pointe vers $RESOLVED_IP (Attendu: $PUBLIC_IP)"
        DNS_ERROR=true
    else
        echo -e "  [${GREEN}OK${NC}] $d : $RESOLVED_IP"
    fi
done

if [ "$DNS_ERROR" = true ]; then
    echo -e "\n${RED}$T_DNS_WARN${NC}"
    read -p "$T_CONT (o/N) : " FORCE_DNS
    if [[ ! "$FORCE_DNS" =~ ^[oOeyY]$ ]]; then exit 1; fi
fi

# ==============================================================================
# 4. INFOS INSTANCE & SUPERADMIN
# ==============================================================================
echo -e "\n${GREEN}--- INFOS INSTANCE & ADMIN ---${NC}"
read -p "Billing Email [${OLD_SA_EMAIL}] : " B_EMAIL; B_EMAIL=${B_EMAIL:-$OLD_SA_EMAIL}
read -p "Company Name [${OLD_SA_LAST}] : " B_COMPANY; B_COMPANY=${B_COMPANY:-$OLD_SA_LAST}
read -p "Password SuperAdmin [${OLD_SA_PASS}] : " B_SA_PASS; B_SA_PASS=${B_SA_PASS:-$OLD_SA_PASS}

# ==============================================================================
# 4.1. RECAPTCHA (NOUVELLE SECTION)
# ==============================================================================
echo -e "\n${GREEN}$T_CAPTCHA_TITLE${NC}"
# Si OLD_CAPTCHA_SITE existe, il s'affiche entre [], sinon vide.
read -p "$T_CAPTCHA_SITE [${OLD_CAPTCHA_SITE}] : " IN_CAPTCHA_SITE
CAPTCHA_SITE_KEY=${IN_CAPTCHA_SITE:-$OLD_CAPTCHA_SITE}

read -p "$T_CAPTCHA_SECRET [${OLD_CAPTCHA_SECRET}] : " IN_CAPTCHA_SECRET
CAPTCHA_SECRET_KEY=${IN_CAPTCHA_SECRET:-$OLD_CAPTCHA_SECRET}

# ==============================================================================
# 5. QUESTIONS VPN
# ==============================================================================
echo -e "\n${GREEN}$T_VPN_Q${NC}"
read -p "VPN Gateway IP [${OLD_VPN_IP:-10.16.0.1}] : " V_IP; VPN_SERVER_IP=${V_IP:-${OLD_VPN_IP:-10.16.0.1}}
read -p "VPN Network [${OLD_VPN_NET:-10.16.0.0}] : " V_NET; VPN_NETWORK=${V_NET:-${OLD_VPN_NET:-10.16.0.0}}
read -p "VPN Mask [${OLD_VPN_MASK:-255.255.0.0}] : " V_MASK; VPN_NETMASK=${V_MASK:-${OLD_VPN_MASK:-255.255.0.0}}
read -p "VPN Prefix [${OLD_VPN_PREF:-16}] : " V_PREF; VPN_NETMASK_PREFIX=${V_PREF:-${OLD_VPN_PREF:-16}}
read -p "VPN Port [${OLD_VPN_PORT:-1194}] : " V_PORT; VPN_PORT=${V_PORT:-${OLD_VPN_PORT:-1194}}

# ==============================================================================
# 6. APPEL API MASTER (GESTION ERREURS AMÉLIORÉE)
# ==============================================================================
echo -e "\n${BLUE}$T_API_SEND${NC}"

# Capture du JSON et du Code HTTP
API_OUT=$(curl -s -w "\n%{http_code}" --location "${MASTER_API_URL}/api/instances/register" \
--header "Accept: application/json" \
--header "Authorization: Bearer ${PARTNER_TOKEN}" \
--form "billing_email=$B_EMAIL" \
--form "company=$B_COMPANY" \
--form "app_url=https://${DOMAIN_NAME}")

API_RESPONSE=$(echo "$API_OUT" | head -n -1)
HTTP_STATUS=$(echo "$API_OUT" | tail -n 1)
MASTER_TOKEN=$(echo "$API_RESPONSE" | jq -r '.data.master_token // empty')

if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
    echo -e "${GREEN}[OK] $T_API_SUCCESS${NC}"
else
    # Récupération du message d'erreur du JSON
    SERVER_MSG=$(echo "$API_RESPONSE" | jq -r '.message // .error // "Unknown Error"')
    echo -e "${RED}[ERREUR] Master API (Code: $HTTP_STATUS)${NC}"
    echo -e "${RED}Message : $SERVER_MSG${NC}"

    if [ "$IS_UPDATE" == "true" ] && [ -n "$OLD_MASTER_TOKEN" ]; then
        echo -e "${YELLOW}Conservation de l'ancien token.${NC}"
        MASTER_TOKEN=$OLD_MASTER_TOKEN
    else
        echo -e "${RED}Impossible de continuer.${NC}"
        exit 1
    fi
fi

# ==============================================================================
# 7. GÉNÉRATION .ENV
# ==============================================================================
cat > .env <<EOF
# =====================================================
# APPLICATION LARAVEL
# =====================================================
APP_NAME=cloutik
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=https://${DOMAIN_NAME}
DOCKER_MODE=true
TRUST_PROXIES=true
RUN_MIGRATIONS=true
RUN_SEED=true
RUN_NPM_BUILD=true
TELESCOPE_PATH=admin/monitoring
TELESCOPE_ENABLED=false

# =====================================================
# VAULT CONFIGURATION (NEW)
# =====================================================
VAULT_ADDR=http://vault:8200
VAULT_TOKEN=root
VAULT_TOKEN_FILE=/vault/tokens/.tokens/cloutik_token

# =====================================================
# ROUTES & SUBDOMAINS
# =====================================================
ROUTE_DOMAIN=${DOMAIN_NAME}
ROUTE_API_INTERF_SUBDOMAIN=api-interf.${DOMAIN_NAME}
ROUTE_API_ADMIN_SUBDOMAIN=api-admin.${DOMAIN_NAME}
ROUTE_API_SUBDOMAIN=api.${DOMAIN_NAME}

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
FTP_PASSIVEPORTS="30000-30599"
FTP_BASE_DIRECTORY=/var/www/html/cloutik
TAG=1.0
EOF

# =====================================================
# 8. PERMISSIONS
# =====================================================
mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
sudo chown -R 33:33 storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

echo -e "\n${GREEN}[OK] Configuration Terminée.${NC}"