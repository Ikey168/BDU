# Cloudflare Infrastructure Configuration
# This Terraform configuration manages DNS and SSL settings for debating.de

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  
  # Configure backend for state management (uncomment and configure as needed)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cloudflare/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configure Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Variables
variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "zone_name" {
  description = "The domain name to manage"
  type        = string
  default     = "debating.de"
}

variable "pages_project_name" {
  description = "Cloudflare Pages project name"
  type        = string
  default     = "bdu-website"
}

variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

# Data source for the zone (assumes zone already exists)
data "cloudflare_zone" "main" {
  name = var.zone_name
}

# DNS Records
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.zone_name
  value   = "192.0.2.1"  # Placeholder IP, will be overridden by Pages
  type    = "A"
  proxied = true
  comment = "Root domain - managed by Cloudflare Pages"
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.main.id
  name    = "www"
  value   = var.zone_name
  type    = "CNAME"
  proxied = true
  comment = "WWW subdomain - redirects to root"
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.main.id
  name    = "api"
  value   = var.zone_name
  type    = "CNAME"
  proxied = true
  comment = "API subdomain for Workers"
}

# Email Records (optional)
resource "cloudflare_record" "mx" {
  zone_id  = data.cloudflare_zone.main.id
  name     = var.zone_name
  value    = "mail.debating.de"
  type     = "MX"
  priority = 10
  proxied  = false
  comment  = "Mail server record"
}

resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.zone_name
  value   = "v=spf1 include:_spf.google.com ~all"
  type    = "TXT"
  comment = "SPF record for email security"
}

resource "cloudflare_record" "dmarc" {
  zone_id = data.cloudflare_zone.main.id
  name    = "_dmarc"
  value   = "v=DMARC1; p=quarantine; rua=mailto:dmarc@debating.de"
  type    = "TXT"
  comment = "DMARC record for email security"
}

# SSL/TLS Configuration
resource "cloudflare_zone_settings_override" "main" {
  zone_id = data.cloudflare_zone.main.id
  
  settings {
    # SSL/TLS
    ssl                      = "full_strict"
    always_use_https        = "on"
    min_tls_version         = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                 = "zrt"
    automatic_https_rewrites = "on"
    
    # Security
    security_level          = "medium"
    challenge_ttl           = 1800
    privacy_pass           = "on"
    security_header {
      enabled = true
    }
    
    # Performance
    brotli                 = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    rocket_loader          = "on"
    mirage                = "on"
    polish                = "lossless"
    webp                  = "on"
    
    # Caching
    browser_cache_ttl      = 14400  # 4 hours
    always_online         = "off"
    development_mode      = "off"
    
    # Other settings
    ipv6                  = "on"
    websockets           = "on"
    opportunistic_onion  = "on"
    pseudo_ipv4          = "off"
    ip_geolocation       = "on"
    email_obfuscation    = "on"
    server_side_exclude  = "on"
    hotlink_protection   = "off"
  }
}

# Page Rules for redirects and caching
resource "cloudflare_page_rule" "redirect_to_www" {
  zone_id  = data.cloudflare_zone.main.id
  target   = "${var.zone_name}/*"
  priority = 1
  status   = "active"

  actions {
    forwarding_url {
      status_code = 301
      url         = "https://www.${var.zone_name}/$1"
    }
  }
}

resource "cloudflare_page_rule" "cache_static_assets" {
  zone_id  = data.cloudflare_zone.main.id
  target   = "*.${var.zone_name}/*.{css,js,png,jpg,jpeg,gif,ico,svg,woff,woff2}"
  priority = 2
  status   = "active"

  actions {
    cache_level         = "cache_everything"
    edge_cache_ttl     = 2592000  # 30 days
    browser_cache_ttl  = 2592000  # 30 days
  }
}

# HSTS Header
resource "cloudflare_page_rule" "hsts_header" {
  zone_id  = data.cloudflare_zone.main.id
  target   = "*.${var.zone_name}/*"
  priority = 3
  status   = "active"

  actions {
    security_header {
      enabled = true
      strict_transport_security {
        enabled     = true
        max_age     = 15768000  # 6 months
        include_subdomains = true
        preload     = true
      }
    }
  }
}

# Rate Limiting (requires Pro plan or higher)
# resource "cloudflare_rate_limit" "api_rate_limit" {
#   zone_id   = data.cloudflare_zone.main.id
#   threshold = 100
#   period    = 60
#   match {
#     request {
#       url_pattern = "*.${var.zone_name}/api/*"
#       schemes     = ["HTTPS"]
#       methods     = ["GET", "POST", "PUT", "DELETE"]
#     }
#   }
#   action {
#     mode    = "ban"
#     timeout = 600
#   }
#   correlate {
#     by = "nat"
#   }
#   disabled = false
#   description = "Rate limit API endpoints"
# }

# Bot Management (requires Pro plan or higher)
# resource "cloudflare_bot_management" "main" {
#   zone_id                = data.cloudflare_zone.main.id
#   enable_js              = true
#   fight_mode             = true
#   using_latest_model     = true
# }

# Access Application (optional - for admin areas)
# resource "cloudflare_access_application" "admin" {
#   zone_id          = data.cloudflare_zone.main.id
#   name             = "Admin Area"
#   domain           = "admin.${var.zone_name}"
#   type             = "self_hosted"
#   session_duration = "24h"
# }

# Outputs
output "zone_id" {
  description = "Cloudflare Zone ID"
  value       = data.cloudflare_zone.main.id
}

output "zone_name" {
  description = "Zone name"
  value       = var.zone_name
}

output "nameservers" {
  description = "Cloudflare nameservers"
  value       = data.cloudflare_zone.main.name_servers
}

output "dns_records" {
  description = "Created DNS records"
  value = {
    root = cloudflare_record.root.hostname
    www  = cloudflare_record.www.hostname
    api  = cloudflare_record.api.hostname
  }
}
