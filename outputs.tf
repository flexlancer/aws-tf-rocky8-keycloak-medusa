output "public_ssh_controller_key" {
  value = tls_private_key.controller_private_key.public_key_openssh
}
output "rds_password" {
  #sensitive = true
  value = random_string.rdspassword.result
}
