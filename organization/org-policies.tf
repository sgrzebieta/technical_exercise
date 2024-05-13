locals {
    organization_policies =[
        // Access management policies
        "storage.uniformBucketLevelAccess",
        "compute.requireOsLogin",

        // IAM policies
        "iam.automaticIamGrantsForDefaultServiceAccounts",
        "iam.disableServiceAccountKeyCreation",
        "iam.disableServiceAccountKeyUpload",
        "constraints/iam.allowedPolicyMemberDomains",

        // VM policies
        "compute.disableNestedVirtualization",
        "compute.disableSerialPortAccess",
        "compute.disableGuestAttributesAccess",
        "constraints/compute.vmExternalIpAccess",

        // Network policies
        "compute.skipDefaultNetworkCreation",
        "compute.restrictXpnProjectLienRemoval",
        "compute.disableVpcExternalIpv6",
        "compute.setNewProjectDefaultToZonalDNSOnly",
        "constraints/storage.publicAccessPrevention",
        "constraints/compute.restrictProtocolForwardingCreationForTypes",

        // SQL network policies
        "sql.restrictPublicIp",
        "sql.restrictAuthorizedNetworks",

        // Miscellaneous
        "constraints/essentialcontacts.allowedContactDomains",
    ]
}

module "organization_policies_type_boolean" {
  source   = "../terraform-google-modules/org-policy/google"
  version  = "5.2.2"
  for_each = local.organization_policies

  organization_id = var.org_id
  policy_for      = "organization"
  policy_type     = "boolean"
  enforce         = "true"
  constraint      = "constraints/${each.value}"
}