variable "project_id" {
  type        = string
  description = "(required) project_id to deploy reseorces to"
}

variable "region" {
  type        = string
  description = "(required) Region to deploy resorces to"
  default     = "australia-southeast1"
}

variable "zones" {
  type        = list(any)
  description = "(required) Zones to deploy to"
  default     = ["australia-southeast1-a", "australia-southeast1-b", "australia-southeast1-c"]
}

variable "additional_metadata" {
  type        = map(any)
  description = "Additional metadata to attach to the instance"
  default     = {}
}

