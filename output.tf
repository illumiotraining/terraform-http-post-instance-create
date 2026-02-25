# outputs.tf (multi-account)
# If you set var.account_count = 1, these outputs behave like your current ones,
# just wrapped as single-element lists.

output "message" {
  description = "Message from the API response (index-aligned)."
  value       = [for r in local.responses : r.message]
}

output "user_email" {
  description = "Primary user email for each created tenant (index-aligned)."
  value       = [for r in local.responses : r.users[0].email]
}

output "apikey_id" {
  description = "API key ID for the primary user (index-aligned)."
  value       = [for r in local.responses : r.users[0].apikey.keyId]
  sensitive   = true
}

output "apikey_secret" {
  description = "API key secret for the primary user (index-aligned)."
  value       = [for r in local.responses : r.users[0].apikey.secret]
  sensitive   = true
}

output "apikey_success" {
  description = "API key success flag for the primary user (index-aligned)."
  value       = [for r in local.responses : r.users[0].apikey.success]
}

output "magiclink" {
  description = "Magic link for the primary user (index-aligned)."
  value       = [for r in local.responses : r.users[0].magiclink]
  sensitive   = true
}

output "tenant_id" {
  description = "Tenant ID (index-aligned)."
  value       = [for r in local.responses : r.tenant.id]
}

output "org_id" {
  description = "Org/Core ID (index-aligned)."
  value       = [for r in local.responses : r.tenant.core.id]
}

output "pce_fqdn" {
  description = "PCE FQDN assigned (index-aligned)."
  value       = [for r in local.responses : r.tenant.core.pceFqdn]
}

output "saApiKey_keyId" {
  description = "Service account API key ID (index-aligned)."
  value       = [for r in local.responses : r.tenant.saApiKey.keyId]
  sensitive   = true
}

output "saApiKey_secret" {
  description = "Service account API key secret (index-aligned)."
  value       = [for r in local.responses : r.tenant.saApiKey.secret]
  sensitive   = true
}

output "saApiKey_success" {
  description = "Service account API key success flag (index-aligned)."
  value       = [for r in local.responses : r.tenant.saApiKey.success]
}

output "expiration_days" {
  description = "Tenant expiration (days) used for this run."
  value       = var.expiration_days
}

# Optional: keep a raw debug output for troubleshooting
# output "debug_raw_responses" {
#   value     = local.responses
#   sensitive = true
# }
