variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "lb_internal" {
  description = "If true, the LB will be internal"
  type        = bool
  default     = false
}

variable "lb_type" {
  description = "The type of load balancer to create. Possible values are application or network"
  type        = string
  default     = "application"
}

variable "lb_subnets" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "lb_enable_deletion_protection" {
  description = "If true, deletion of the LB will be protected"
  type        = bool
  default     = false
}

variable "lb_security_groups" {
  description = "A list of security group IDs to attach to the LB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID to create the LB in"
  type        = string
}

variable "lb_target_group_type" {
  type    = string
  default = "instanse"
}

variable "lb_target_group_port" {
  type    = number
  default = 80
}

variable "lb_target_group_protocol" {
  type    = string
  default = "HTTP"
}

variable "lb_target_group_attachment_instance_ids" {
  description = "A list of instance IDs to attach to the target group"
  type        = list(string)
}

variable "lb_target_group_attachment_port" {
  type = number
}
