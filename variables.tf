variable "region" {
  default = "us-east-2"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ssh_public_key" {
  description = "Conteúdo da chave pública SSH"
}

variable "ssh_cidr" {
  description = "Seu IP liberado para SSH (ex.: 200.10.20.30/32)"
}
