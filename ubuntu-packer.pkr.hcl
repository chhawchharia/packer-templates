provisioner "shell" {
  inline = [
    "echo 'BYOI Test Build'",
    "sudo apt-get update",
    "sudo apt-get install -y nginx",
    "nginx -v"
  ]
}
