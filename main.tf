terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "http" {}

# One random number per account
resource "random_integer" "email_num" {
  count = var.account_count
  min   = 100000
  max   = 999999
}

locals {
  # License start and end dates
  start = formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timestamp())
  end   = formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timeadd(local.start, "${var.license_days * 24}h"))

  # JSON payloads (one per account)
  payloads = [
    for i in range(var.account_count) : jsonencode({
      first_name    = "Illumio"
      last_name     = "Training"
      email         = "trn+${random_integer.email_num[i].result}@illumio.com"
      company_name  = "Illumio account ${random_integer.email_num[i].result}"
      domain        = "console.illum.io"
      preferred_region = var.preferred_region
      country_code     = var.country_code
      pce_fqdn         = var.pce_cluster_name
      store_rbac       = true
      optional_features = ["magiclinks_enabled"]

      settings = {
        auth = {
          passkeys = {
            enabled = true
          }
          passwords = {
            enabled = true
          }
        }
      }

      licenses = {
        insights = {
          type              = var.insights_type
          start             = local.start
          end               = local.end
          name              = "Illumio Insights Free Trial"
          planName          = "Insights Trial Plan"
          workloadsLicensed = var.insights_workloads
        }
        segmentation = {
          type              = var.segmentation_type
          start             = local.start
          end               = local.end
          name              = "Illumio Segmentation Free Trial"
          planName          = "Segmentation Free Trial"
          workloadsLicensed = var.segmentation_workloads
        }
      }

      generateApiKey    = true
      tenant_expiration = var.expiration_days
    })
  ]
}

# Send POST request (one per account)
data "http" "post_request" {
  count  = var.account_count
  url    = var.base_url
  method = "POST"

  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = var.api_token
  }

  request_body = local.payloads[count.index]

  retry {
    attempts     = 9
    min_delay_ms = 1000
    max_delay_ms = 5000
  }
}

# --- Parse JSON responses (list) ---
locals {
  responses = [
    for r in data.http.post_request : jsondecode(r.response_body)
  ]
}
