variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Subdomain for the application"
  type        = string
}

variable "alb_dns_name" {
  description = "alb DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "alb hosted zone ID"
  type        = string
}
