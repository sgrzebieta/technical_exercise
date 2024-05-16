output "subnets_ids" {
  value       = module.vpc.subnets_ids
  description = "A list of subnets ids that have been created"
}

output "subnets_secondary_ranges" {
  value       = module.vpc.subnets_secondary_ranges
  description = "A list of secondary ranges associated with subnets"
}
