output "id" {
  description = "The ID of the load balancer"
  value       = try(aws_lb.this.id, null)
}

output "arn" {
  description = "The ARN of the load balancer"
  value       = try(aws_lb.this.arn, null)
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.this.dns_name, null)
}

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = aws_lb_listener.this
}

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = aws_lb_target_group.this
}
