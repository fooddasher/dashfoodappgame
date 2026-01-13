#!/bin/bash
# ============================================================================
# Food Dash - Keystore Generation Script (macOS/Linux)
# ============================================================================
# This script generates a JKS keystore for signing Android apps.
# 
# SECURITY GUARANTEES:
#   - Does NOT read any system information (IP, location, username, etc.)
#   - Does NOT auto-fill any fields
#   - All values are manually entered by the user
#   - Outputs base64-encoded keystore for GitHub Secrets
#
# REQUIREMENTS:
#   - Java JDK installed (keytool must be in PATH)
#   - Bash shell
#
# USAGE:
#   chmod +x scripts/generate_keystore.sh
#   ./scripts/generate_keystore.sh
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  FOOD DASH - ANDROID KEYSTORE GENERATOR${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}This script will generate a release keystore for signing your app.${NC}"
echo ""
echo -e "${GREEN}SECURITY NOTICE:${NC}"
echo -e "${GREEN}  - This script does NOT collect any system information${NC}"
echo -e "${GREEN}  - This script does NOT read your IP address or location${NC}"
echo -e "${GREEN}  - This script does NOT auto-fill any values${NC}"
echo -e "${GREEN}  - All information is manually entered by YOU${NC}"
echo ""
echo -e "${CYAN}============================================================${NC}"
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}[ERROR] keytool not found. Please install Java JDK.${NC}"
    echo -e "${YELLOW}Download from: https://adoptium.net/${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] keytool found in PATH${NC}"
echo ""

echo -e "${CYAN}Please enter the following company/organization details:${NC}"
echo -e "${YELLOW}(All fields are required and must be entered manually)${NC}"
echo ""

# ============================================
# COLLECT COMPANY DETAILS (Manual Entry Only)
# ============================================

# 1. Organization Name
while true; do
    read -p "1. Organization/Company Name (e.g., FoodDash Inc): " ORG_NAME
    if [ -n "$ORG_NAME" ]; then break; fi
    echo -e "${RED}   [!] Organization name cannot be empty${NC}"
done

# 2. Organizational Unit
while true; do
    read -p "2. Organizational Unit (e.g., Mobile Development): " ORG_UNIT
    if [ -n "$ORG_UNIT" ]; then break; fi
    echo -e "${RED}   [!] Organizational unit cannot be empty${NC}"
done

# 3. City/Locality
while true; do
    read -p "3. City/Locality (e.g., San Francisco): " CITY
    if [ -n "$CITY" ]; then break; fi
    echo -e "${RED}   [!] City cannot be empty${NC}"
done

# 4. State/Province
while true; do
    read -p "4. State/Province (e.g., California): " STATE
    if [ -n "$STATE" ]; then break; fi
    echo -e "${RED}   [!] State cannot be empty${NC}"
done

# 5. Country Code (2 letters)
while true; do
    read -p "5. Country Code (2 letters, e.g., US): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
    if [ ${#COUNTRY} -eq 2 ]; then break; fi
    echo -e "${RED}   [!] Country code must be exactly 2 letters${NC}"
done

# 6. Key Alias
while true; do
    read -p "6. Key Alias (e.g., fooddash-release-key): " KEY_ALIAS
    if [ -n "$KEY_ALIAS" ] && [[ ! "$KEY_ALIAS" =~ [[:space:]] ]]; then break; fi
    echo -e "${RED}   [!] Key alias cannot be empty or contain spaces${NC}"
done

echo ""
echo -e "${CYAN}Now enter your passwords:${NC}"
echo -e "${YELLOW}(These will be used to protect your keystore - SAVE THEM SECURELY)${NC}"
echo ""

# 7. Keystore Password
while true; do
    read -s -p "7. Keystore Password (min 6 characters): " KEYSTORE_PASSWORD
    echo ""
    if [ ${#KEYSTORE_PASSWORD} -ge 6 ]; then break; fi
    echo -e "${RED}   [!] Password must be at least 6 characters${NC}"
done

# 8. Key Password
echo ""
read -p "8. Use same password for key alias? (Y/N): " USE_SAME
if [[ "$USE_SAME" =~ ^[Yy]$ ]]; then
    KEY_PASSWORD="$KEYSTORE_PASSWORD"
    echo -e "${GREEN}   [OK] Using same password for key alias${NC}"
else
    while true; do
        read -s -p "   Enter Key Password (min 6 characters): " KEY_PASSWORD
        echo ""
        if [ ${#KEY_PASSWORD} -ge 6 ]; then break; fi
        echo -e "${RED}   [!] Password must be at least 6 characters${NC}"
    done
fi

# Build Distinguished Name (DN)
DNAME="CN=$ORG_NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"

# Output file paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORE_FILE="$SCRIPT_DIR/../fooddash-release.jks"
BASE64_FILE="$SCRIPT_DIR/../fooddash-keystore-base64.txt"

# Remove existing keystore if present
if [ -f "$KEYSTORE_FILE" ]; then
    echo ""
    read -p "Keystore file already exists. Overwrite? (Y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborted. Existing keystore not modified."
        exit 0
    fi
    rm -f "$KEYSTORE_FILE"
fi

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  GENERATING KEYSTORE...${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# Generate keystore using keytool
keytool -genkeypair -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -dname "$DNAME" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD"

if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "${RED}[ERROR] Keystore file was not created${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Keystore generated successfully!${NC}"

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  ENCODING KEYSTORE TO BASE64...${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# Convert keystore to base64
base64 -i "$KEYSTORE_FILE" > "$BASE64_FILE"

echo -e "${GREEN}[OK] Base64 encoded keystore saved to: fooddash-keystore-base64.txt${NC}"

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  SUCCESS! KEYSTORE GENERATED${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${CYAN}Files created:${NC}"
echo "  1. fooddash-release.jks (JKS keystore)"
echo "  2. fooddash-keystore-base64.txt (Base64 encoded)"
echo ""
echo -e "${YELLOW}============================================================${NC}"
echo -e "${YELLOW}  GITHUB SECRETS SETUP INSTRUCTIONS${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo ""
echo -e "${CYAN}Go to your GitHub repository:${NC}"
echo "  Settings -> Secrets and variables -> Actions -> New repository secret"
echo ""
echo -e "${CYAN}Add the following secrets:${NC}"
echo ""
echo "  Secret Name                    Value"
echo "  ------------------------------ --------------------------------"
echo "  FOODDASH_KEYSTORE_BASE64       (contents of fooddash-keystore-base64.txt)"
echo "  FOODDASH_KEYSTORE_PASSWORD     (your keystore password)"
echo "  FOODDASH_KEY_ALIAS             $KEY_ALIAS"
echo "  FOODDASH_KEY_PASSWORD          (your key password)"
echo ""
echo -e "${RED}============================================================${NC}"
echo -e "${RED}  IMPORTANT SECURITY REMINDERS${NC}"
echo -e "${RED}============================================================${NC}"
echo ""
echo -e "${YELLOW}  1. NEVER commit the .jks or base64.txt files to git!${NC}"
echo -e "${YELLOW}  2. Store passwords in a secure password manager${NC}"
echo -e "${YELLOW}  3. The keystore is required for ALL future app updates${NC}"
echo -e "${YELLOW}  4. Backup the .jks file to a secure offline location${NC}"
echo -e "${YELLOW}  5. Delete the base64.txt file after adding to GitHub Secrets${NC}"
echo ""
echo -e "${CYAN}============================================================${NC}"
echo ""

# Clear sensitive variables
unset KEYSTORE_PASSWORD
unset KEY_PASSWORD

echo "Script completed."
