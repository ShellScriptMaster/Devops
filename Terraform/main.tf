provider  "alicloud" {
  region = "cn-hongkong"  
  access_key = ""
  secret_key = ""
}

variable "cidr-block-list" {
  description = "subnet cidr block "
  type = list(string)
}

variable "cidr-block-obj" {
  description = "cidr block obj "
  type = list(object({
    cidr_block = string
    name = string
  }))
}

data "alicloud_zones" "Jacky-zone" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "development-vpc" {
  vpc_name = "Develop-vpc"
  cidr_block = var.cidr-block-list[0]
}

resource "alicloud_vswitch" "dev-subnet-1" {
  vpc_id = alicloud_vpc.development-vpc.id
  cidr_block = "192.168.4.0/24" 
  zone_id = data.alicloud_zones.Jacky-zone.zones.0.id
  vswitch_name = "development-vswitch-1"
}

resource "alicloud_vswitch" "dev-subnet-2" {
  vpc_id = alicloud_vpc.development-vpc.id
  cidr_block = var.cidr-block-obj[1].cidr_block
  zone_id = data.alicloud_zones.Jacky-zone.zones.0.id
  vswitch_name = "development-vswitch-2"
  tags = {
    name:var.cidr-block-obj[1].name
    ip:var.cidr-block-obj[1].cidr_block
  }
}

data "alicloud_vpcs" "existing_vpc" {
  cidr_block = var.cidr-block-list[0]
  vpc_name = "Develop-vpc"
}

output "vpc-id" {
  value = alicloud_vpc.development-vpc.id 
}

output "subnet-id" {
  value = alicloud_vswitch.dev-subnet-1.id
}