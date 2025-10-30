#!/bin/bash
# Expert Bug Bounty Hunter - JavaScript Reconnaissance Script
# Optimized for scanning 1000+ JS files for sensitive information
# Usage: bash js-recon-commands.sh /path/to/js/folder

TARGET_DIR="${1:-.}"
OUTPUT_DIR="./recon-output"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting JavaScript reconnaissance on: $TARGET_DIR"
echo "[*] Output will be saved to: $OUTPUT_DIR"
echo ""

# ============================================================================
# 1. API Keys & Secrets
# ============================================================================
echo "[+] Searching for API Keys and Secrets..."
grep -rEioh \
  --include="*.js" \
  '(api[_-]?key|apikey|api[_-]?secret|access[_-]?key|secret[_-]?key|client[_-]?secret|aws[_-]?secret)["\s:=]+[a-zA-Z0-9_\-]{20,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/01-api-keys.txt"

# AWS Keys
grep -rEioh \
  --include="*.js" \
  '(AKIA[0-9A-Z]{16}|aws_access_key_id|aws_secret_access_key)' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/01-api-keys.txt"

# Google API Keys
grep -rEioh \
  --include="*.js" \
  'AIza[0-9A-Za-z_\-]{35}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/01-api-keys.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/01-api-keys.txt") potential API keys"

# ============================================================================
# 2. Authentication Tokens
# ============================================================================
echo "[+] Searching for Authentication Tokens..."
grep -rEioh \
  --include="*.js" \
  '(bearer|token|auth|authorization)["\s:=]+[a-zA-Z0-9_\-\.]{20,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/02-auth-tokens.txt"

# JWT Tokens
grep -rEioh \
  --include="*.js" \
  'eyJ[a-zA-Z0-9_\-]*\.eyJ[a-zA-Z0-9_\-]*\.[a-zA-Z0-9_\-]*' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/02-auth-tokens.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/02-auth-tokens.txt") potential tokens"

# ============================================================================
# 3. URLs & Endpoints (API, Internal, S3, etc.)
# ============================================================================
echo "[+] Extracting URLs and Endpoints..."
grep -rEoh \
  --include="*.js" \
  'https?://[a-zA-Z0-9./?=_\-&%#]+' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/03-urls-all.txt"

# API Endpoints
grep -rEioh \
  --include="*.js" \
  'https?://[^"'\'']*/(api|v[0-9]|rest|graphql|endpoint)[^"'\'']*' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/03-api-endpoints.txt"

# S3 Buckets
grep -rEioh \
  --include="*.js" \
  'https?://[a-zA-Z0-9\-\.]*\.?s3[a-zA-Z0-9\-\.]*\.amazonaws\.com[^"'\'']*' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/03-s3-buckets.txt"

# Internal/Private IPs
grep -rEoh \
  --include="*.js" \
  '(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|localhost:[0-9]{2,5})' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/03-internal-ips.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/03-urls-all.txt") URLs"
echo "   Found $(wc -l < "$OUTPUT_DIR/03-api-endpoints.txt") API endpoints"
echo "   Found $(wc -l < "$OUTPUT_DIR/03-s3-buckets.txt") S3 buckets"
echo "   Found $(wc -l < "$OUTPUT_DIR/03-internal-ips.txt") internal IPs"

# ============================================================================
# 4. Database Credentials & Connection Strings
# ============================================================================
echo "[+] Searching for Database Credentials..."
grep -rEioh \
  --include="*.js" \
  '(mongodb|mysql|postgres|redis|jdbc|database)[:\s]*["\047][^"'\'']{10,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/04-db-credentials.txt"

# Connection strings
grep -rEioh \
  --include="*.js" \
  '(mongodb(\+srv)?|mysql|postgresql|redis)://[^"'\'']*' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/04-db-credentials.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/04-db-credentials.txt") potential DB credentials"

# ============================================================================
# 5. Passwords & Credentials
# ============================================================================
echo "[+] Searching for Passwords..."
grep -rEioh \
  --include="*.js" \
  '(password|passwd|pwd|pass)["\s:=]+[^"\s]{4,}' \
  "$TARGET_DIR" | grep -v 'type="password"' | sort -u > "$OUTPUT_DIR/05-passwords.txt"

# Username patterns
grep -rEioh \
  --include="*.js" \
  '(username|user|login)["\s:=]+[a-zA-Z0-9_\-\.@]{3,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/05-usernames.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/05-passwords.txt") potential passwords"
echo "   Found $(wc -l < "$OUTPUT_DIR/05-usernames.txt") usernames"

# ============================================================================
# 6. Email Addresses
# ============================================================================
echo "[+] Extracting Email Addresses..."
grep -rEioh \
  --include="*.js" \
  '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/06-emails.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/06-emails.txt") email addresses"

# ============================================================================
# 7. Third-Party Service Keys
# ============================================================================
echo "[+] Searching for Third-Party Service Keys..."

# Firebase
grep -rEioh \
  --include="*.js" \
  'firebase[a-zA-Z0-9_\-]*["\s:=]+[a-zA-Z0-9_\-]{20,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/07-third-party-keys.txt"

# Stripe
grep -rEioh \
  --include="*.js" \
  '(sk|pk)_(test|live)_[a-zA-Z0-9]{24,}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/07-third-party-keys.txt"

# Twilio
grep -rEioh \
  --include="*.js" \
  'AC[a-z0-9]{32}|SK[a-z0-9]{32}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/07-third-party-keys.txt"

# SendGrid
grep -rEioh \
  --include="*.js" \
  'SG\.[a-zA-Z0-9_\-]{22}\.[a-zA-Z0-9_\-]{43}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/07-third-party-keys.txt"

# Slack
grep -rEioh \
  --include="*.js" \
  'xox[baprs]-[0-9]{10,12}-[0-9]{10,12}-[a-zA-Z0-9]{24,}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/07-third-party-keys.txt"

# reCAPTCHA (site keys)
grep -rEioh \
  --include="*.js" \
  '6L[a-zA-Z0-9_\-]{38,}' \
  "$TARGET_DIR" | sort -u >> "$OUTPUT_DIR/07-third-party-keys.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/07-third-party-keys.txt") third-party keys"

# ============================================================================
# 8. Sensitive Function Calls (eval, innerHTML, etc.)
# ============================================================================
echo "[+] Searching for Dangerous Functions..."
grep -rn \
  --include="*.js" \
  -E '(eval\(|innerHTML|outerHTML|document\.write|setTimeout\(|setInterval\(|Function\()' \
  "$TARGET_DIR" > "$OUTPUT_DIR/08-dangerous-functions.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/08-dangerous-functions.txt") dangerous function calls"

# ============================================================================
# 9. Debug/Development Flags
# ============================================================================
echo "[+] Searching for Debug Flags..."
grep -rEioh \
  --include="*.js" \
  '(debug|DEBUG|dev|DEV|test|TEST|staging|STAGING)["\s:=]+(true|1|on)' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/09-debug-flags.txt"

# Console logs with sensitive data
grep -rn \
  --include="*.js" \
  'console\.(log|debug|info|warn|error)' \
  "$TARGET_DIR" | head -500 > "$OUTPUT_DIR/09-console-logs.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/09-debug-flags.txt") debug flags"
echo "   Found $(wc -l < "$OUTPUT_DIR/09-console-logs.txt") console logs (first 500)"

# ============================================================================
# 10. Comments with Sensitive Info
# ============================================================================
echo "[+] Searching for Sensitive Comments..."
grep -rEi \
  --include="*.js" \
  '(//|/\*).*(todo|fixme|hack|password|secret|key|token|api|credential|username)' \
  "$TARGET_DIR" | head -500 > "$OUTPUT_DIR/10-sensitive-comments.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/10-sensitive-comments.txt") sensitive comments (first 500)"

# ============================================================================
# 11. CSRF/XSRF Tokens
# ============================================================================
echo "[+] Searching for CSRF Tokens..."
grep -rEioh \
  --include="*.js" \
  '(csrf|xsrf)[_-]?token["\s:=]+[a-zA-Z0-9_\-]{20,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/11-csrf-tokens.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/11-csrf-tokens.txt") CSRF tokens"

# ============================================================================
# 12. Subdomain & Domain References
# ============================================================================
echo "[+] Extracting Subdomains..."
grep -rEoh \
  --include="*.js" \
  'https?://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}' \
  "$TARGET_DIR" | sed 's|https\?://||g' | cut -d'/' -f1 | sort -u > "$OUTPUT_DIR/12-domains.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/12-domains.txt") unique domains"

# ============================================================================
# 13. Source Map References
# ============================================================================
echo "[+] Searching for Source Maps..."
grep -rl \
  --include="*.js" \
  'sourceMappingURL' \
  "$TARGET_DIR" > "$OUTPUT_DIR/13-sourcemap-files.txt"

grep -rEoh \
  --include="*.js" \
  'sourceMappingURL=([^\s]+)' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/13-sourcemap-urls.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/13-sourcemap-files.txt") files with source maps"

# ============================================================================
# 14. Hardcoded Crypto/Encryption Keys
# ============================================================================
echo "[+] Searching for Encryption Keys..."
grep -rEioh \
  --include="*.js" \
  '(encrypt|decrypt|crypto|aes|rsa)[_-]?key["\s:=]+[a-zA-Z0-9+/=]{16,}' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/14-crypto-keys.txt"

# Private keys
grep -rn \
  --include="*.js" \
  'BEGIN (RSA |EC |DSA )?PRIVATE KEY' \
  "$TARGET_DIR" > "$OUTPUT_DIR/14-private-keys.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/14-crypto-keys.txt") crypto keys"
echo "   Found $(wc -l < "$OUTPUT_DIR/14-private-keys.txt") private keys"

# ============================================================================
# 15. GraphQL Queries & Introspection
# ============================================================================
echo "[+] Searching for GraphQL..."
grep -rn \
  --include="*.js" \
  -E '(query|mutation|subscription).*\{' \
  "$TARGET_DIR" | head -200 > "$OUTPUT_DIR/15-graphql-queries.txt"

grep -rEioh \
  --include="*.js" \
  'https?://[^"'\'']*graphql[^"'\'']*' \
  "$TARGET_DIR" | sort -u > "$OUTPUT_DIR/15-graphql-endpoints.txt"

echo "   Found $(wc -l < "$OUTPUT_DIR/15-graphql-queries.txt") GraphQL queries (first 200)"
echo "   Found $(wc -l < "$OUTPUT_DIR/15-graphql-endpoints.txt") GraphQL endpoints"

# ============================================================================
# Summary Report
# ============================================================================
echo ""
echo "================================"
echo "   RECONNAISSANCE COMPLETE"
echo "================================"
echo ""
echo "Results saved in: $OUTPUT_DIR"
echo ""
echo "Quick summary:"
find "$OUTPUT_DIR" -type f -name "*.txt" | while read file; do
    count=$(wc -l < "$file")
    filename=$(basename "$file")
    printf "  %-40s %5d results\n" "$filename" "$count"
done

echo ""
echo "[!] Next steps:"
echo "    1. Review high-priority files: 01-api-keys.txt, 02-auth-tokens.txt, 05-passwords.txt"
echo "    2. Test API endpoints from 03-api-endpoints.txt"
echo "    3. Check if S3 buckets are public (03-s3-buckets.txt)"
echo "    4. Validate JWT tokens (02-auth-tokens.txt)"
echo "    5. Test for XSS via dangerous functions (08-dangerous-functions.txt)"
echo ""
