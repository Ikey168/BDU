#!/bin/bash

# DNS and SSL Verification Script for debating.de
# This script verifies DNS configuration and SSL setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="${1:-debating.de}"
WWW_DOMAIN="www.${DOMAIN}"

echo -e "${BLUE}=== DNS and SSL Verification for ${DOMAIN} ===${NC}\n"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Function to check DNS resolution
check_dns() {
    echo -e "${BLUE}=== DNS Resolution Checks ===${NC}"
    
    echo "Checking A record for ${DOMAIN}..."
    if command_exists dig; then
        A_RECORD=$(dig +short A ${DOMAIN})
        if [ -n "$A_RECORD" ]; then
            print_status 0 "${DOMAIN} resolves to: ${A_RECORD}"
        else
            print_status 1 "${DOMAIN} does not resolve to an A record"
        fi
    else
        echo -e "${YELLOW}dig command not found, skipping A record check${NC}"
    fi
    
    echo "Checking CNAME record for ${WWW_DOMAIN}..."
    if command_exists dig; then
        CNAME_RECORD=$(dig +short CNAME ${WWW_DOMAIN})
        if [ -n "$CNAME_RECORD" ]; then
            print_status 0 "${WWW_DOMAIN} CNAME points to: ${CNAME_RECORD}"
        else
            # Check if www resolves to A record instead
            WWW_A_RECORD=$(dig +short A ${WWW_DOMAIN})
            if [ -n "$WWW_A_RECORD" ]; then
                print_status 0 "${WWW_DOMAIN} resolves to A record: ${WWW_A_RECORD}"
            else
                print_status 1 "${WWW_DOMAIN} does not resolve"
            fi
        fi
    else
        echo -e "${YELLOW}dig command not found, skipping CNAME check${NC}"
    fi
    
    # Check nameservers
    echo "Checking nameservers..."
    if command_exists dig; then
        NS_RECORDS=$(dig +short NS ${DOMAIN})
        if echo "$NS_RECORDS" | grep -q "cloudflare"; then
            print_status 0 "Domain uses Cloudflare nameservers"
            echo "$NS_RECORDS" | while read -r ns; do
                echo "  - $ns"
            done
        else
            print_status 1 "Domain not using Cloudflare nameservers"
            echo "$NS_RECORDS" | while read -r ns; do
                echo "  - $ns"
            done
        fi
    fi
    
    echo ""
}

# Function to check HTTP/HTTPS responses
check_http() {
    echo -e "${BLUE}=== HTTP/HTTPS Response Checks ===${NC}"
    
    # Check HTTP redirect to HTTPS
    echo "Checking HTTP to HTTPS redirect for ${DOMAIN}..."
    if command_exists curl; then
        HTTP_RESPONSE=$(curl -s -I -L "http://${DOMAIN}" | head -1)
        if echo "$HTTP_RESPONSE" | grep -q "200"; then
            HTTP_LOCATION=$(curl -s -I "http://${DOMAIN}" | grep -i "location:" | head -1)
            if echo "$HTTP_LOCATION" | grep -q "https://"; then
                print_status 0 "HTTP redirects to HTTPS"
            else
                print_status 1 "HTTP does not redirect to HTTPS"
            fi
        else
            print_status 1 "HTTP request failed: $HTTP_RESPONSE"
        fi
    else
        echo -e "${YELLOW}curl command not found, skipping HTTP checks${NC}"
    fi
    
    # Check HTTPS response
    echo "Checking HTTPS response for ${DOMAIN}..."
    if command_exists curl; then
        HTTPS_RESPONSE=$(curl -s -I "https://${DOMAIN}" | head -1)
        if echo "$HTTPS_RESPONSE" | grep -q "200"; then
            print_status 0 "HTTPS responds successfully"
        else
            print_status 1 "HTTPS request failed: $HTTPS_RESPONSE"
        fi
    fi
    
    # Check WWW redirect
    echo "Checking WWW redirect..."
    if command_exists curl; then
        WWW_RESPONSE=$(curl -s -I -L "https://${WWW_DOMAIN}" | head -1)
        if echo "$WWW_RESPONSE" | grep -q "200"; then
            print_status 0 "WWW subdomain responds successfully"
        else
            print_status 1 "WWW subdomain failed: $WWW_RESPONSE"
        fi
    fi
    
    echo ""
}

# Function to check SSL certificate
check_ssl() {
    echo -e "${BLUE}=== SSL Certificate Checks ===${NC}"
    
    if command_exists openssl; then
        echo "Checking SSL certificate for ${DOMAIN}..."
        
        # Get certificate info
        CERT_INFO=$(echo | openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:443 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            print_status 0 "SSL certificate retrieved successfully"
            
            # Check certificate validity
            NOT_AFTER=$(echo "$CERT_INFO" | grep "notAfter" | cut -d= -f2)
            echo "  Certificate expires: $NOT_AFTER"
            
            # Check issuer
            ISSUER=$(echo "$CERT_INFO" | grep "issuer" | cut -d= -f2-)
            echo "  Issued by: $ISSUER"
            
            # Check if it's a Cloudflare certificate
            if echo "$ISSUER" | grep -q -i "cloudflare\|let.s.encrypt"; then
                print_status 0 "Certificate issued by trusted CA"
            else
                print_status 1 "Certificate not from expected CA"
            fi
            
        else
            print_status 1 "Failed to retrieve SSL certificate"
        fi
        
        # Check SSL Labs rating (if online)
        echo "For detailed SSL analysis, visit:"
        echo "https://www.ssllabs.com/ssltest/analyze.html?d=${DOMAIN}"
        
    else
        echo -e "${YELLOW}openssl command not found, skipping SSL checks${NC}"
    fi
    
    echo ""
}

# Function to check security headers
check_security_headers() {
    echo -e "${BLUE}=== Security Headers Check ===${NC}"
    
    if command_exists curl; then
        echo "Checking security headers for ${DOMAIN}..."
        
        HEADERS=$(curl -s -I "https://${DOMAIN}")
        
        # Check HSTS
        if echo "$HEADERS" | grep -q -i "strict-transport-security"; then
            print_status 0 "HSTS header present"
            HSTS=$(echo "$HEADERS" | grep -i "strict-transport-security" | cut -d: -f2-)
            echo "  $HSTS"
        else
            print_status 1 "HSTS header missing"
        fi
        
        # Check Content Security Policy
        if echo "$HEADERS" | grep -q -i "content-security-policy"; then
            print_status 0 "CSP header present"
        else
            print_status 1 "CSP header missing (recommended)"
        fi
        
        # Check X-Frame-Options
        if echo "$HEADERS" | grep -q -i "x-frame-options"; then
            print_status 0 "X-Frame-Options header present"
        else
            print_status 1 "X-Frame-Options header missing (recommended)"
        fi
        
        # Check X-Content-Type-Options
        if echo "$HEADERS" | grep -q -i "x-content-type-options"; then
            print_status 0 "X-Content-Type-Options header present"
        else
            print_status 1 "X-Content-Type-Options header missing (recommended)"
        fi
        
    else
        echo -e "${YELLOW}curl command not found, skipping security header checks${NC}"
    fi
    
    echo ""
}

# Function to check Cloudflare integration
check_cloudflare() {
    echo -e "${BLUE}=== Cloudflare Integration Check ===${NC}"
    
    if command_exists curl; then
        # Check for Cloudflare headers
        CF_HEADERS=$(curl -s -I "https://${DOMAIN}")
        
        if echo "$CF_HEADERS" | grep -q -i "cf-ray\|cloudflare"; then
            print_status 0 "Cloudflare integration detected"
            
            # Extract CF-Ray header
            CF_RAY=$(echo "$CF_HEADERS" | grep -i "cf-ray" | cut -d: -f2- | tr -d ' \r')
            if [ -n "$CF_RAY" ]; then
                echo "  CF-Ray: $CF_RAY"
            fi
            
            # Check caching
            if echo "$CF_HEADERS" | grep -q -i "cf-cache-status"; then
                CACHE_STATUS=$(echo "$CF_HEADERS" | grep -i "cf-cache-status" | cut -d: -f2- | tr -d ' \r')
                echo "  Cache Status: $CACHE_STATUS"
            fi
            
        else
            print_status 1 "Cloudflare integration not detected"
        fi
    fi
    
    echo ""
}

# Function to perform speed test
check_performance() {
    echo -e "${BLUE}=== Performance Check ===${NC}"
    
    if command_exists curl; then
        echo "Measuring response time for ${DOMAIN}..."
        
        RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "https://${DOMAIN}")
        echo "  Response time: ${RESPONSE_TIME}s"
        
        # Performance recommendations
        if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l 2>/dev/null || echo "0") )); then
            print_status 0 "Good response time (< 1s)"
        elif (( $(echo "$RESPONSE_TIME < 3.0" | bc -l 2>/dev/null || echo "0") )); then
            echo -e "${YELLOW}⚠${NC} Moderate response time (1-3s)"
        else
            print_status 1 "Slow response time (> 3s)"
        fi
        
        echo "For detailed performance analysis, visit:"
        echo "https://www.webpagetest.org/"
        echo "https://pagespeed.web.dev/"
        
    else
        echo -e "${YELLOW}curl command not found, skipping performance checks${NC}"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "Domain: $DOMAIN"
    echo "WWW Domain: $WWW_DOMAIN"
    echo ""
    
    check_dns
    check_http
    check_ssl
    check_security_headers
    check_cloudflare
    check_performance
    
    echo -e "${BLUE}=== Summary ===${NC}"
    echo "Verification complete for ${DOMAIN}"
    echo ""
    echo "Next steps if issues found:"
    echo "1. Check Cloudflare DNS settings"
    echo "2. Verify SSL/TLS configuration"
    echo "3. Review Page Rules and redirects"
    echo "4. Monitor for DNS propagation (up to 48 hours)"
    echo ""
    echo "For additional help, see:"
    echo "- .github/CLOUDFLARE_DNS_SSL.md"
    echo "- https://developers.cloudflare.com/"
}

# Run main function
main
