variable "vpc_name" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "enable_dns_support" {
  type = bool
}
variable "enable_dns_hostnames" {
  type = bool
}

# ---------------------- Subnets ---------------------- #

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks. Must be the same length as availability_zones"
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnet_names" {
  description = "Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  type = list(string)
}
