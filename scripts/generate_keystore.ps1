# ============================================================================
# Food Dash - Keystore Generation Script (Windows PowerShell)
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
#   - PowerShell 5.1 or later
#
# USAGE:
#   .\scripts\generate_keystore.ps1
# ============================================================================

# Strict mode for safety
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Banner
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  FOOD DASH - ANDROID KEYSTORE GENERATOR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will generate a release keystore for signing your app." -ForegroundColor Yellow
Write-Host ""
Write-Host "SECURITY NOTICE:" -ForegroundColor Green
Write-Host "  - This script does NOT collect any system information" -ForegroundColor Green
Write-Host "  - This script does NOT read your IP address or location" -ForegroundColor Green
Write-Host "  - This script does NOT auto-fill any values" -ForegroundColor Green
Write-Host "  - All information is manually entered by YOU" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if keytool is available
try {
    $null = Get-Command keytool -ErrorAction Stop
    Write-Host "[OK] keytool found in PATH" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] keytool not found. Please install Java JDK and ensure it's in your PATH." -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Please enter the following company/organization details:" -ForegroundColor Cyan
Write-Host "(All fields are required and must be entered manually)" -ForegroundColor Yellow
Write-Host ""

# ============================================
# COLLECT COMPANY DETAILS (Manual Entry Only)
# ============================================

# 1. Organization Name
do {
    $orgName = Read-Host "1. Organization/Company Name (e.g., FoodDash Inc)"
    if ([string]::IsNullOrWhiteSpace($orgName)) {
        Write-Host "   [!] Organization name cannot be empty" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($orgName))

# 2. Organizational Unit
do {
    $orgUnit = Read-Host "2. Organizational Unit (e.g., Mobile Development)"
    if ([string]::IsNullOrWhiteSpace($orgUnit)) {
        Write-Host "   [!] Organizational unit cannot be empty" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($orgUnit))

# 3. City/Locality
do {
    $city = Read-Host "3. City/Locality (e.g., San Francisco)"
    if ([string]::IsNullOrWhiteSpace($city)) {
        Write-Host "   [!] City cannot be empty" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($city))

# 4. State/Province
do {
    $state = Read-Host "4. State/Province (e.g., California)"
    if ([string]::IsNullOrWhiteSpace($state)) {
        Write-Host "   [!] State cannot be empty" -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($state))

# 5. Country Code (2 letters)
do {
    $country = Read-Host "5. Country Code (2 letters, e.g., US)"
    $country = $country.ToUpper()
    if ($country.Length -ne 2) {
        Write-Host "   [!] Country code must be exactly 2 letters" -ForegroundColor Red
        $country = ""
    }
} while ([string]::IsNullOrWhiteSpace($country))

# 6. Key Alias
do {
    $keyAlias = Read-Host "6. Key Alias (e.g., fooddash-release-key)"
    if ([string]::IsNullOrWhiteSpace($keyAlias)) {
        Write-Host "   [!] Key alias cannot be empty" -ForegroundColor Red
    }
    if ($keyAlias -match '\s') {
        Write-Host "   [!] Key alias cannot contain spaces" -ForegroundColor Red
        $keyAlias = ""
    }
} while ([string]::IsNullOrWhiteSpace($keyAlias))

Write-Host ""
Write-Host "Now enter your passwords:" -ForegroundColor Cyan
Write-Host "(These will be used to protect your keystore - SAVE THEM SECURELY)" -ForegroundColor Yellow
Write-Host ""

# 7. Keystore Password
do {
    $keystorePassword = Read-Host "7. Keystore Password (min 6 characters)" -AsSecureString
    $keystorePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword)
    )
    if ($keystorePasswordPlain.Length -lt 6) {
        Write-Host "   [!] Password must be at least 6 characters" -ForegroundColor Red
        $keystorePasswordPlain = ""
    }
} while ([string]::IsNullOrWhiteSpace($keystorePasswordPlain))

# 8. Key Password (can be same as keystore password)
Write-Host ""
$useSamePassword = Read-Host "8. Use same password for key alias? (Y/N)"
if ($useSamePassword -eq "Y" -or $useSamePassword -eq "y") {
    $keyPasswordPlain = $keystorePasswordPlain
    Write-Host "   [OK] Using same password for key alias" -ForegroundColor Green
} else {
    do {
        $keyPassword = Read-Host "   Enter Key Password (min 6 characters)" -AsSecureString
        $keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword)
        )
        if ($keyPasswordPlain.Length -lt 6) {
            Write-Host "   [!] Password must be at least 6 characters" -ForegroundColor Red
            $keyPasswordPlain = ""
        }
    } while ([string]::IsNullOrWhiteSpace($keyPasswordPlain))
}

# Build Distinguished Name (DN)
$dname = "CN=$orgName, OU=$orgUnit, O=$orgName, L=$city, ST=$state, C=$country"

# Output file path - use current directory to avoid path issues
$keystoreFileName = "fooddash-release.jks"
$keystorePath = Join-Path -Path (Get-Location) -ChildPath $keystoreFileName

# Remove existing keystore if present
if (Test-Path $keystorePath) {
    Write-Host ""
    $overwrite = Read-Host "Keystore file already exists. Overwrite? (Y/N)"
    if ($overwrite -ne "Y" -and $overwrite -ne "y") {
        Write-Host "Aborted. Existing keystore not modified." -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $keystorePath -Force
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GENERATING KEYSTORE..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Generate keystore using keytool with direct invocation
# Using & operator with escaped/quoted arguments for paths with spaces
try {
    # Use the call operator (&) with proper argument handling
    & keytool `
        -genkeypair `
        -v `
        -keystore "$keystorePath" `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -alias $keyAlias `
        -dname "$dname" `
        -storepass $keystorePasswordPlain `
        -keypass $keyPasswordPlain
    
    if ($LASTEXITCODE -ne 0) {
        throw "keytool failed with exit code $LASTEXITCODE"
    }
    
    Write-Host ""
    Write-Host "[OK] Keystore generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to generate keystore: $_" -ForegroundColor Red
    exit 1
}

# Verify keystore was created
if (-not (Test-Path $keystorePath)) {
    Write-Host "[ERROR] Keystore file was not created" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ENCODING KEYSTORE TO BASE64..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Convert keystore to base64
$keystoreBytes = [System.IO.File]::ReadAllBytes($keystorePath)
$keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)

# Save base64 to file for easy copying
$base64FilePath = Join-Path -Path (Get-Location) -ChildPath "fooddash-keystore-base64.txt"
$keystoreBase64 | Out-File -FilePath $base64FilePath -Encoding ASCII -NoNewline

Write-Host "[OK] Base64 encoded keystore saved to: fooddash-keystore-base64.txt" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  SUCCESS! KEYSTORE GENERATED" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files created in current directory:" -ForegroundColor Cyan
Write-Host "  1. $keystoreFileName (JKS keystore)" -ForegroundColor White
Write-Host "  2. fooddash-keystore-base64.txt (Base64 encoded)" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  GITHUB SECRETS SETUP INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Go to your GitHub repository:" -ForegroundColor Cyan
Write-Host "  Settings -> Secrets and variables -> Actions -> New repository secret" -ForegroundColor White
Write-Host ""
Write-Host "Add the following secrets:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Secret Name                    Value" -ForegroundColor Yellow
Write-Host "  ------------------------------ --------------------------------" -ForegroundColor Gray
Write-Host "  FOODDASH_KEYSTORE_BASE64       (contents of fooddash-keystore-base64.txt)" -ForegroundColor White
Write-Host "  FOODDASH_KEYSTORE_PASSWORD     (your keystore password)" -ForegroundColor White
Write-Host "  FOODDASH_KEY_ALIAS             $keyAlias" -ForegroundColor White
Write-Host "  FOODDASH_KEY_PASSWORD          (your key password)" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Red
Write-Host "  IMPORTANT SECURITY REMINDERS" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red
Write-Host ""
Write-Host "  1. NEVER commit the .jks or base64.txt files to git!" -ForegroundColor Yellow
Write-Host "  2. Store passwords in a secure password manager" -ForegroundColor Yellow
Write-Host "  3. The keystore is required for ALL future app updates" -ForegroundColor Yellow
Write-Host "  4. Backup the .jks file to a secure offline location" -ForegroundColor Yellow
Write-Host "  5. Delete the base64.txt file after adding to GitHub Secrets" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Clear sensitive variables from memory
$keystorePasswordPlain = $null
$keyPasswordPlain = $null
$keystoreBase64 = $null
[System.GC]::Collect()

Write-Host "Script completed. Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
