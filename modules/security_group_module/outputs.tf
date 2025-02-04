output "sg_id" {
  value = aws_security_group.this.id
}

output "all_sg_ids" {
  value = aws_security_group.all[*].id
}

