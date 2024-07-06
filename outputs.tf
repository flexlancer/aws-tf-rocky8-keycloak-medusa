resource "local_file" "tf_localfile_output" {
  content         = <<-EOT
  [keycloak-master-instance]
  ${aws_instance.keycloak-master-instance.private_ip}
  [keycloak-master-instance]
  ${aws_instance.keycloak-master-instance.public_dns} 
  EOT
  file_permission = 0400
  filename        = format("%s/%s", abspath(path.root), "keycloak_ips.txt")
}

output "public_ssh_controller_key" {
  value = tls_private_key.controller_private_key.public_key_openssh
}
output "rds_password" {
  #sensitive = true
  value = random_string.rdspassword.result
}