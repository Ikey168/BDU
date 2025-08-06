# Cloudflare DNS and SSL Configuration Guide

This guide covers setting up the `debating.de` domain (or subdomain) with Cloudflare, including DNS configuration and SSL/TLS setup.

## Overview

This configuration will:
1. Register/configure the `debating.de` zone in Cloudflare
2. Point DNS records to Cloudflare Pages
3. Enable SSL/TLS with Full (strict) mode
4. Configure proper domain routing

## Prerequisites

- Access to domain registrar for `debating.de`
- Cloudflare account with appropriate permissions
- Cloudflare Pages project already set up

## Step 1: Add Domain to Cloudflare

### Option A: Full Domain Management
If you want Cloudflare to manage the entire `debating.de` domain:

1. **Add Site to Cloudflare**:
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Click "Add a Site"
   - Enter `debating.de`
   - Select appropriate plan (Free is sufficient for basic needs)

2. **DNS Scan**:
   - Cloudflare will scan existing DNS records
   - Review and keep necessary records
   - Note the Cloudflare nameservers provided

3. **Update Nameservers**:
   - Go to your domain registrar
   - Replace existing nameservers with Cloudflare nameservers:
     ```
     amit.ns.cloudflare.com
     reza.ns.cloudflare.com
     ```
   - Save changes (propagation takes 24-48 hours)

### Option B: Subdomain Only (CNAME Setup)
If you only want to use a subdomain like `www.debating.de`:

1. **CNAME Method**:
   - No need to change nameservers
   - Configure CNAME record at your current DNS provider
   - Point to Cloudflare Pages URL

## Step 2: Configure DNS Records

### For Full Domain Management:

Navigate to **DNS > Records** in Cloudflare Dashboard:

#### Primary Records:
```
Type: A
Name: debating.de (or @)
IPv4: 192.0.2.1 (placeholder - will be handled by Pages)
Proxy: ✅ Proxied (orange cloud)

Type: CNAME  
Name: www
Target: debating.de
Proxy: ✅ Proxied (orange cloud)
```

#### Additional Recommended Records:
```
# Redirect common subdomains to www
Type: CNAME
Name: app
Target: debating.de
Proxy: ✅ Proxied

Type: CNAME
Name: api  
Target: debating.de
Proxy: ✅ Proxied

# Email (if needed)
Type: MX
Name: debating.de
Mail server: your-mail-server.com
Priority: 10
Proxy: ❌ DNS only (grey cloud)

# Email security
Type: TXT
Name: debating.de
Content: "v=spf1 include:_spf.google.com ~all"

Type: TXT
Name: _dmarc
Content: "v=DMARC1; p=quarantine; rua=mailto:dmarc@debating.de"
```

### For Subdomain Only:
At your current DNS provider:
```
Type: CNAME
Name: www
Target: your-pages-project.pages.dev
```

## Step 3: Connect Cloudflare Pages

1. **Access Pages Project**:
   - Go to [Cloudflare Pages](https://dash.cloudflare.com/pages)
   - Select your project (e.g., "bdu-website")

2. **Add Custom Domain**:
   - Click "Custom domains" tab
   - Click "Set up a custom domain"
   - Enter your domain: `debating.de`
   - Add additional domains: `www.debating.de`

3. **Verify Domain Ownership**:
   - Cloudflare will verify domain ownership
   - This may require DNS propagation (up to 24 hours)

## Step 4: Configure SSL/TLS

### SSL/TLS Encryption Mode:

1. **Go to SSL/TLS Overview**:
   - Navigate to **SSL/TLS > Overview**
   - Select encryption mode: **Full (strict)**

2. **SSL/TLS Settings**:
   ```
   Encryption Mode: Full (strict)
   - Encrypts traffic between browser and Cloudflare
   - Encrypts traffic between Cloudflare and origin server
   - Validates origin server certificate
   ```

### Edge Certificates:

1. **Universal SSL**:
   - Navigate to **SSL/TLS > Edge Certificates**
   - Ensure "Universal SSL" is enabled
   - Certificate should show as "Active"

2. **Advanced Certificate Manager** (Optional - Paid feature):
   - Provides more control over certificates
   - Custom hostnames
   - Longer validity periods

### Additional SSL Settings:

1. **Always Use HTTPS**:
   - Navigate to **SSL/TLS > Edge Certificates**
   - Enable "Always Use HTTPS"
   - Automatically redirects HTTP to HTTPS

2. **HTTP Strict Transport Security (HSTS)**:
   - Enable HSTS for additional security
   - Max Age: 6 months (15768000 seconds)
   - Include subdomains: ✅
   - Preload: ✅ (optional)

3. **Minimum TLS Version**:
   - Set to TLS 1.2 or higher
   - Recommended: TLS 1.2

## Step 5: Page Rules and Redirects

### Redirect Rules:
Navigate to **Rules > Redirect Rules**:

```
Rule 1: Redirect to www
If: Hostname equals "debating.de"
Then: Dynamic redirect to "https://www.debating.de$1"
Status code: 301 (Permanent)

Rule 2: Force HTTPS
If: Scheme equals "http"  
Then: Dynamic redirect to "https://$1"
Status code: 301 (Permanent)
```

### Cache Rules (Optional):
```
Rule: Cache Static Assets
If: File extension matches "css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2"
Then: Cache level = Cache everything
Edge TTL: 1 month
```

## Step 6: Security Configuration

### Security Level:
- Navigate to **Security > Settings**
- Set Security Level: **Medium** (or High for stricter security)

### Bot Fight Mode:
- Enable "Bot Fight Mode" for basic bot protection
- Consider upgrading to Bot Management for advanced features

### Rate Limiting (Pro/Business plans):
```
Rule: API Rate Limiting
If: URI path contains "/api/"
Then: Rate limit to 100 requests per minute per IP
```

## Step 7: Performance Optimization

### Caching:
- Navigate to **Caching > Configuration**
- Caching Level: **Standard**
- Browser Cache TTL: **4 hours**

### Speed:
- Navigate to **Speed > Optimization**
- Auto Minify: Enable CSS, JS, HTML
- Brotli: Enable
- Early Hints: Enable

### Images:
- Polish: **Lossless** (for better quality)
- WebP: Enable
- Mirage: Enable (mobile optimization)

## Step 8: Monitoring and Analytics

### Analytics:
- Navigate to **Analytics & Logs > Web Analytics**
- Enable Web Analytics for visitor insights

### Security Events:
- Monitor **Security > Events** for security incidents
- Set up alerts for unusual activity

## Verification Steps

### 1. DNS Propagation:
```bash
# Check DNS propagation
dig debating.de
dig www.debating.de

# Check from multiple locations
nslookup debating.de 8.8.8.8
nslookup www.debating.de 1.1.1.1
```

### 2. SSL Certificate:
```bash
# Check SSL certificate
openssl s_client -connect debating.de:443 -servername debating.de

# Online tools:
# https://www.ssllabs.com/ssltest/
# https://whatsmydns.net/
```

### 3. Website Loading:
```bash
# Test website response
curl -I https://debating.de
curl -I https://www.debating.de

# Check redirects
curl -I http://debating.de
```

## Troubleshooting

### Common Issues:

**1. DNS Not Resolving**
- Wait for DNS propagation (24-48 hours)
- Check nameservers are correctly set
- Verify DNS records in Cloudflare

**2. SSL Certificate Errors**
- Ensure SSL mode is "Full (strict)"
- Check origin server has valid SSL certificate
- Wait for certificate provisioning (up to 24 hours)

**3. Redirect Loops**
- Check redirect rules aren't conflicting
- Verify SSL/TLS encryption mode
- Review Page Rules configuration

**4. Site Not Loading**
- Verify Cloudflare Pages domain configuration
- Check DNS record proxy status (orange cloud)
- Review security settings for blocking

### Debug Commands:
```bash
# Test DNS resolution
nslookup debating.de
dig debating.de A
dig www.debating.de CNAME

# Test SSL
openssl s_client -connect debating.de:443
curl -I https://debating.de

# Test redirects
curl -I -L http://debating.de
curl -I -L https://debating.de
```

## Security Best Practices

1. **Enable DNSSEC** (if supported by registrar)
2. **Use strong SSL/TLS configuration**
3. **Implement proper redirect rules**
4. **Monitor security events regularly**
5. **Keep DNS records minimal and necessary**
6. **Use Cloudflare Access for admin areas**
7. **Enable two-factor authentication on Cloudflare account**

## Maintenance

### Regular Tasks:
- Monitor SSL certificate renewal (automatic with Cloudflare)
- Review security events monthly
- Update DNS records as needed
- Monitor website performance metrics
- Review and update security settings quarterly

### Annual Tasks:
- Review domain registration renewal
- Audit DNS records and remove unused entries
- Update redirect rules as site structure changes
- Review and update security policies

## Support Resources

- [Cloudflare Documentation](https://developers.cloudflare.com/)
- [DNS Management Guide](https://developers.cloudflare.com/dns/)
- [SSL/TLS Configuration](https://developers.cloudflare.com/ssl/)
- [Pages Custom Domains](https://developers.cloudflare.com/pages/platform/custom-domains/)
- [Cloudflare Community](https://community.cloudflare.com/)
