variable "domain_name" {
  default = "resume.oliyidetoyyib.com"
  type = string
  description = "Domain name"
}

variable "hosted_zone_id" {
  type = string
  default = "Z05157532VTDT6Z6CUEER"
  description = "Hosted zone id"
}

variable "acm" {
  type = string
  default = "arn:aws:acm:us-east-1:252313380597:certificate/8587aff1-e304-4ea3-9992-d2405a18fde7"
}