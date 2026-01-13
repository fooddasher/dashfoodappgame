# Food Dash - CI/CD Setup Guide

This document explains how to set up automated Android builds using GitHub Actions.

---

## 🔒 Security Guarantees

**The keystore generation script (`scripts/generate_keystore.ps1` / `scripts/generate_keystore.sh`):**

- ✅ Does **NOT** collect any system information
- ✅ Does **NOT** read your IP address
- ✅ Does **NOT** read your geographic location
- ✅ Does **NOT** read your username or computer name
- ✅ Does **NOT** auto-fill any fields
- ✅ All values are manually entered by the user
- ✅ Passwords are entered securely (hidden input)

**The GitHub Actions workflow:**

- ✅ Secrets are **never** printed to logs
- ✅ Keystore is decoded at runtime and **deleted** after build
- ✅ Uses GitHub's built-in secret masking
- ✅ Builds are signed with your release key (not debug)

---

## 📋 Prerequisites

1. **Java JDK 17+** installed locally (for keystore generation)
   - Download from: https://adoptium.net/
   - Verify: `keytool -help` should work in terminal

2. **GitHub repository** with this codebase pushed

---

## 🔑 Step 1: Generate Your Keystore

### On Windows (PowerShell):

```powershell
cd "path\to\Food Dash"
.\scripts\generate_keystore.ps1
```

### On macOS/Linux (Bash):

```bash
cd path/to/Food\ Dash
chmod +x scripts/generate_keystore.sh
./scripts/generate_keystore.sh
```

### You will be prompted for:

| # | Field | Example |
|---|-------|---------|
| 1 | Organization/Company Name | FoodDash Inc |
| 2 | Organizational Unit | Mobile Development |
| 3 | City/Locality | San Francisco |
| 4 | State/Province | California |
| 5 | Country Code (2 letters) | US |
| 6 | Key Alias | fooddash-release-key |
| 7 | Keystore Password | (your secure password) |
| 8 | Key Password | (same or different password) |

### Output Files:

After running the script, you will have:

1. `fooddash-release.jks` - Your keystore file (BACKUP THIS SECURELY!)
2. `fooddash-keystore-base64.txt` - Base64 encoded keystore for GitHub

---

## 🔐 Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"** for each:

| Secret Name | Value |
|-------------|-------|
| `FOODDASH_KEYSTORE_BASE64` | Contents of `fooddash-keystore-base64.txt` |
| `FOODDASH_KEYSTORE_PASSWORD` | Your keystore password |
| `FOODDASH_KEY_ALIAS` | The key alias you entered (e.g., `fooddash-release-key`) |
| `FOODDASH_KEY_PASSWORD` | Your key password |

### How to copy the base64 content:

**Windows:**
```powershell
Get-Content fooddash-keystore-base64.txt | Set-Clipboard
```

**macOS:**
```bash
cat fooddash-keystore-base64.txt | pbcopy
```

**Linux:**
```bash
cat fooddash-keystore-base64.txt | xclip -selection clipboard
```

---

## 🚀 Step 3: Trigger the Build

The workflow automatically runs on:

- Every **push** to `main` or `master` branch
- Every **pull request** to `main` or `master` branch
- **Manual trigger** via GitHub Actions UI

### To manually trigger:

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. Select **"Build Android Release"** workflow
4. Click **"Run workflow"** button
5. Select branch and click **"Run workflow"**

---

## 📦 Step 4: Download Build Artifacts

After a successful build:

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **"Artifacts"** section
4. Download:
   - `food-dash-apk-{commit}` - Signed APK file
   - `food-dash-aab-{commit}` - Signed AAB file (for Play Store)

Artifacts are retained for **30 days**.

---

## 🔧 Workflow Configuration

### File Location
```
.github/workflows/build-release.yml
```

### Key Settings

| Setting | Value | Description |
|---------|-------|-------------|
| Flutter Version | `3.24.0` | Update in workflow file as needed |
| Java Version | `17` | Required for Android builds |
| Artifact Retention | 30 days | How long artifacts are kept |

### To update Flutter version:

Edit `.github/workflows/build-release.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.24.0'  # Change this
```

---

## ⚠️ Important Security Reminders

### DO:
- ✅ Store `fooddash-release.jks` in a secure offline location (USB drive, safe)
- ✅ Use a password manager for your keystore passwords
- ✅ Keep the keystore forever (required for ALL future app updates)
- ✅ Delete `fooddash-keystore-base64.txt` after adding to GitHub Secrets

### DON'T:
- ❌ **NEVER** commit `.jks` files to git
- ❌ **NEVER** commit `key.properties` to git
- ❌ **NEVER** commit `*-base64.txt` files to git
- ❌ **NEVER** share your keystore or passwords publicly
- ❌ **NEVER** lose your keystore (you cannot update your app without it!)

---

## 🔄 Local Development

For local development, you can:

1. **Build debug APK** (no signing required):
   ```bash
   flutter build apk --debug
   ```

2. **Build release APK locally** (requires keystore setup):
   
   Create `android/key.properties`:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=YOUR_KEY_ALIAS
   storeFile=../fooddash-release.jks
   ```
   
   Then build:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

---

## 🐛 Troubleshooting

### Build fails with "Keystore not found"
- Ensure all 4 GitHub Secrets are correctly set
- Check that `FOODDASH_KEYSTORE_BASE64` is the complete base64 string (no line breaks)

### Build fails with R8/ProGuard errors
- The `proguard-rules.pro` file includes dontwarn rules for Play Core classes
- If new errors appear, add corresponding `-dontwarn` rules

### Build fails with "signing config not found"
- Verify `FOODDASH_KEY_ALIAS` matches exactly what you entered during keystore generation

### Workflow doesn't trigger
- Ensure you're pushing to `main` or `master` branch
- Check that the workflow file exists at `.github/workflows/build-release.yml`

---

## 📱 Uploading to Google Play Store

1. Download the AAB artifact from GitHub Actions
2. Go to [Google Play Console](https://play.google.com/console)
3. Select your app → **Release** → **Production** (or testing track)
4. Upload the `app-release.aab` file
5. Complete the release review process

---

## 📄 Files Reference

| File | Purpose |
|------|---------|
| `.github/workflows/build-release.yml` | GitHub Actions workflow |
| `scripts/generate_keystore.ps1` | Keystore generator (Windows) |
| `scripts/generate_keystore.sh` | Keystore generator (macOS/Linux) |
| `android/app/build.gradle.kts` | Android build configuration |
| `android/app/proguard-rules.pro` | R8/ProGuard rules |
| `android/key.properties` | Local signing config (gitignored) |

---

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section above
2. Review GitHub Actions logs for specific error messages
3. Ensure all prerequisites are correctly installed

---

*Last updated: January 2026*
