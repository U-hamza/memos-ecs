variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  type = string
}


variable "vpc_cidr" {
  type = string
}

variable "public_subnet_1_cidr" {
  type = string
}

variable "public_subnet_2_cidr" {
  type = string
}

variable "private_subnet_1_cidr" {
  type = string
}

variable "private_subnet_2_cidr" {
  type = string
}

variable "availability_zone_1" {
  type = string
}

variable "availability_zone_2" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "image_tag" {
  type = string
}
