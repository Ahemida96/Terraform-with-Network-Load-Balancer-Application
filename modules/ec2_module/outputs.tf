output "instance_id" {
  description = "The ID of the instance"
  value = try(
    aws_instance.this.id,
    null,
  )
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value = try(
    aws_instance.this.availability_zone,
    null,
  )
}

output "arn" {
  description = "The ARN of the instance"
  value = try(
    aws_instance.this.arn,
    null,
  )
}

output "instance_state" {
  description = "The state of the instance"
  value = try(
    aws_instance.this.instance_state,
    null,
  )
}

output "subnet_id" {
  value = aws_instance.this.subnet_id
}

output "private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value = try(
    aws_instance.this.private_dns,
    null,
  )
}

output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value = try(
    aws_instance.this.public_dns,
    null,
  )
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value = try(aws_instance.this.private_ip,
    null,
  )

}


