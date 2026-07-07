variable "akey" {}
variable "skey" {}
variable "hostpassword" {}
variable "dev-cidr-block-obj" {
  type = list(object({
    name = string
    cidr-block = string
  }))
}

variable "instance_info" {
  type = list(object({
    instance_name = string
    host_name = string
    private_ip = string
  }))
}

