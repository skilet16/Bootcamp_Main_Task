variable aws_access_key {
  type        = string
  default     = ""
}

variable aws_secret_key {
  type        = string
  default     = ""
}

variable "region" {
  type        = string
  default     = ""
}

variable "vpc_id" {
  type        = string
  default     = ""
}

variable "allow_ports" {
    type = list(string)
    default= ["80", "22"]
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "common_tags" {
    type = map
    default = {
        Name = "Eriks Bootcamp"
        Owner = "Eriks Masinskis"
        Project = "Bootcamp"
    }
}

variable ansible_user {
  type        = string
  default     = "ubuntu"
}

variable key_pair_name {
  type        = string
  default     = "webserver-bootcamp-eriks-key"
}

variable key_pair_path {
  type        = string
  default     = "ansible/"
}

variable inventory_path {
  type        = string
  default     = "ansible/hosts"
}


