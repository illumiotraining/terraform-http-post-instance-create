terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

resource "random_integer" "email_num" {
  min = 100000
  max = 999999
} 

provider "http" {}

locals {

  # License start and end dates
  start= formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timestamp())
  end  =  formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timeadd(local.start,"${var.license_days * 24}h"))

  # JSON payload (as a string)
   payload = jsonencode({
      first_name = "Illumio"
      last_name  = "Training"
      email             = "trn+${random_integer.email_num.result}@illumio.com"
      company_name      = "Illumio account ${random_integer.email_num.result}"
    domain            = "console.illum.io"
    preferred_region  = "${var.preferred_region}"
    country_code      = "${var.country_code}"
    pce_fqdn          = "${var.pce_cluster_name}"
    store_rbac        = true
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
        type               = "${var.insights_type}"
        start              = "${local.start}"
        end                = "${local.end}"
        name               = "Illumio Insights Free Trial"
        planName           = "Insights Trial Plan"
        workloadsLicensed  = "${var.insights_workloads}"
      },
      segmentation = {
        type               = "${var.segmentation_type}"
        start              = "${local.start}"
        end                = "${local.end}"
        name               = "Illumio Segmentation Free Trial"
        planName           = "Segmentation Free Trial"
        workloadsLicensed  = "${var.segmentation_workloads}"
      }
    }
    generateApiKey    = true
    tenant_expiration = "${var.expiration_days}"
  })
}

# Send POST request
data "http" "post_request" {
  url    = "${var.base_url}"
  method = "POST"

  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "${var.api_token}"
  }

  request_body = local.payload

  retry {
    attempts     = 9             # Total of 10 requests (initial + 9 retries)
    min_delay_ms = 1000           # Minimum delay of 1 seconds
    max_delay_ms = 5000          # Maximum delay of 5 seconds
  }
}


# --- Parse JSON response ---
locals {
  response = jsondecode(data.http.post_request.response_body)
}
