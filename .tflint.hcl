config {
  module = true
  force  = false
}

plugin "oci" {
  enabled = true
}

# Terraform language rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}
