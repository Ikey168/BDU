#!/bin/bash

# Cloudflare DNS and SSL Setup Script
# This script helps with the initial setup and verification

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Cloudflare DNS and SSL Setup for debating.de ===${NC}\n"

# Check if running in the correct directory
if [ ! -f ".github/CLOUDFLARE_DNS_SSL.md" ]; then
    echo -e "${RED}Error: Please run this script from the repository root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}This script will help you set up DNS and SSL for debating.de${NC}\n"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}=== Checking Prerequisites ===${NC}"
    
    # Check if user has necessary tools
    tools=("curl" "dig" "openssl")
    missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${YELLOW}The following tools are missing: ${missing_tools[*]}${NC}"
        echo "Please install them and run this script again."
        echo ""
        echo "On Ubuntu/Debian: sudo apt-get install dnsutils curl openssl"
        echo "On macOS: brew install bind curl openssl"
        echo ""
    else
        echo -e "${GREEN}✓ All required tools are available${NC}"
    fi
    
    echo ""
}

# Function to display setup checklist
show_checklist() {
    echo -e "${BLUE}=== Setup Checklist ===${NC}"
    echo ""
    echo "Before proceeding, ensure you have:"
    echo "□ Access to your domain registrar for debating.de"
    echo "□ Cloudflare account with API access"
    echo "□ Cloudflare Pages project created"
    echo "□ Domain ownership verification completed"
    echo ""
    
    read -p "Have you completed the above steps? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Please complete the prerequisites first.${NC}"
        echo "Refer to .github/CLOUDFLARE_DNS_SSL.md for detailed instructions."
        exit 1
    fi
    echo ""
}

# Function to verify current DNS status
check_current_dns() {
    echo -e "${BLUE}=== Current DNS Status ===${NC}"
    
    echo "Checking current DNS configuration for debating.de..."
    
    # Check A record
    echo -n "A record: "
    A_RECORD=$(dig +short A debating.de 2>/dev/null || echo "Not found")
    echo "$A_RECORD"
    
    # Check WWW CNAME
    echo -n "WWW CNAME: "
    WWW_RECORD=$(dig +short CNAME www.debating.de 2>/dev/null || echo "Not found")
    if [ "$WWW_RECORD" = "Not found" ]; then
        WWW_RECORD=$(dig +short A www.debating.de 2>/dev/null || echo "Not found")
    fi
    echo "$WWW_RECORD"
    
    # Check nameservers
    echo -n "Nameservers: "
    NS_RECORDS=$(dig +short NS debating.de 2>/dev/null || echo "Not found")
    if echo "$NS_RECORDS" | grep -q "cloudflare"; then
        echo -e "${GREEN}Using Cloudflare${NC}"
    else
        echo -e "${YELLOW}Not using Cloudflare${NC}"
        echo "$NS_RECORDS"
    fi
    
    echo ""
}

# Function to test HTTPS and SSL
test_https_ssl() {
    echo -e "${BLUE}=== Testing HTTPS and SSL ===${NC}"
    
    # Test HTTPS connectivity
    echo -n "HTTPS connectivity: "
    if curl -s -I "https://debating.de" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Working${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
    fi
    
    # Test SSL certificate
    echo -n "SSL certificate: "
    if echo | openssl s_client -servername debating.de -connect debating.de:443 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Valid${NC}"
        
        # Get certificate expiry
        CERT_EXPIRY=$(echo | openssl s_client -servername debating.de -connect debating.de:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d= -f2)
        echo "  Expires: $CERT_EXPIRY"
    else
        echo -e "${RED}✗ Invalid or not accessible${NC}"
    fi
    
    echo ""
}

# Function to run full verification
run_verification() {
    echo -e "${BLUE}=== Running Full Verification ===${NC}"
    
    if [ -x "./scripts/verify-dns-ssl.sh" ]; then
        ./scripts/verify-dns-ssl.sh debating.de
    else
        echo -e "${YELLOW}Verification script not found or not executable${NC}"
        echo "Make sure scripts/verify-dns-ssl.sh exists and is executable"
    fi
}

# Function to show next steps
show_next_steps() {
    echo -e "${BLUE}=== Next Steps ===${NC}"
    echo ""
    echo "1. ${YELLOW}Review the configuration:${NC}"
    echo "   - Read .github/CLOUDFLARE_DNS_SSL.md for detailed setup"
    echo "   - Check Cloudflare Dashboard for DNS settings"
    echo "   - Verify SSL/TLS configuration"
    echo ""
    echo "2. ${YELLOW}Apply Infrastructure as Code (optional):${NC}"
    echo "   - Copy infrastructure/terraform.tfvars.example to terraform.tfvars"
    echo "   - Fill in your Cloudflare credentials"
    echo "   - Run: cd infrastructure && terraform init && terraform apply"
    echo ""
    echo "3. ${YELLOW}Set up monitoring:${NC}"
    echo "   - Enable the verify-dns-ssl.yml GitHub Action"
    echo "   - Set up alerts for SSL certificate expiration"
    echo "   - Monitor DNS propagation after changes"
    echo ""
    echo "4. ${YELLOW}Test thoroughly:${NC}"
    echo "   - Test from multiple locations"
    echo "   - Verify redirects work correctly"
    echo "   - Check mobile and desktop performance"
    echo ""
    echo -e "${GREEN}Setup complete! Your domain should now be configured with Cloudflare.${NC}"
}

# Main execution
main() {
    check_prerequisites
    show_checklist
    check_current_dns
    test_https_ssl
    
    echo ""
    read -p "Would you like to run the full verification script? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_verification
    fi
    
    show_next_steps
}

# Run main function
main
