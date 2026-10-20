output "public_instance_id" {
  description = "公有子网实例 ID"
  value       = aws_instance.public.id
}

output "public_private_ip" {
  description = "公有子网实例私有 IP"
  value       = aws_instance.public.private_ip
}

output "private_instance_id" {
  description = "私有子网实例 ID"
  value       = aws_instance.private.id
}

output "private_private_ip" {
  description = "私有子网实例私有 IP"
  value       = aws_instance.private.private_ip
}

output "nat_public_ip" {
  description = "NAT Gateway 公网 IP"
  value       = aws_eip.nat.public_ip
}
