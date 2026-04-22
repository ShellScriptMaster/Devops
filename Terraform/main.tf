provider "alicloud" {
  access_key = var.akey
  secret_key = var.skey
  region = "cn-hongkong"
}

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

data "alicloud_zones" "alicloud-zones-info" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "vpc-dev" {
  cidr_block = var.dev-cidr-block-obj[0].cidr-block
  vpc_name = "Develop-vpc"
  tags = {
    name:var.dev-cidr-block-obj[0].name
    cidr-block:var.dev-cidr-block-obj[0].cidr-block
  }
}

resource "alicloud_vswitch" "subnet-dev" {
  vswitch_name = "Develop-subnet"
  vpc_id = alicloud_vpc.vpc-dev.id
  cidr_block = var.dev-cidr-block-obj[1].cidr-block
  tags = {
    name:var.dev-cidr-block-obj[1].name
    cidr-block:var.dev-cidr-block-obj[1].cidr-block
  }
  zone_id = data.alicloud_zones.alicloud-zones-info.zones.0.id
}

resource "alicloud_route_table" "dev-route-table" {
  description      = "Develop-route-table"
  vpc_id           = alicloud_vpc.vpc-dev.id
  route_table_name = "dev-route-table"
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "dev-rtb-attach" {
  vswitch_id     = alicloud_vswitch.subnet-dev.id
  route_table_id = alicloud_route_table.dev-route-table.id
}

resource "alicloud_security_group" "dev-sec-group" {
  security_group_name = "dev-sec-group"
  vpc_id            = alicloud_vpc.vpc-dev.id
}

resource "alicloud_security_group_rule" "allow-all-inbound-sec-rule" {
  type              = "ingress"  # ingress(inbound) and egress(outbound)
  ip_protocol       = "all"
  nic_type          = "intranet" 
  policy            = "accept"  # accept / drop 
  port_range        = "-1/-1"  # means allow all ip 
  priority          = 1
  security_group_id = alicloud_security_group.dev-sec-group.id
  cidr_ip           = "0.0.0.0/0"
  description       = "allow-all-sec-rule inbound traffic "
}

resource "alicloud_security_group_rule" "allow-all-outbound-sec-rule" {
  type              = "egress"  # ingress(inbound) and egress(outbound)
  ip_protocol       = "all"
  nic_type          = "intranet" 
  policy            = "accept"  # accept / drop 
  port_range        = "-1/-1"  # means allow all ip 
  priority          = 1
  security_group_id = alicloud_security_group.dev-sec-group.id
  cidr_ip           = "0.0.0.0/0"
  description       = "allow-all-sec-rule outbound traffic "

}

data "alicloud_images" "data-dev-ali-img" {
  name_regex = "^rockylinux.*arm64.*20G"
  owners     = "system"
}

resource "alicloud_instance" "ecs-dev-instance-0" {
  # cn-hongkong
  availability_zone = data.alicloud_zones.alicloud-zones-info.zones.0.id
  security_groups   = alicloud_security_group.dev-sec-group.*.id

  # series III
  instance_type              = "ecs.c8y.large"
  system_disk_category       = "cloud_essd"
  system_disk_name           = "ecs-sys-disk-0"
  system_disk_size           = 40
  system_disk_description    = "alicloud ecs system disk 0 "
  system_disk_performance_level  = "PL0"
  description                = "Alicloud ecs develop instance 0"
  private_ip                 = var.instance_info[0].private_ip
  image_id                   = data.alicloud_images.data-dev-ali-img.ids[0]
  instance_name              = var.instance_info[0].instance_name
  vswitch_id                 = alicloud_vswitch.subnet-dev.id
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 100
  instance_charge_type       = "PostPaid"
  spot_strategy              = "NoSpot"
  host_name                  = var.instance_info[0].host_name
  password                   = var.hostpassword
  dry_run                    = false 
}

resource "alicloud_instance" "ecs-dev-instance-1" {
  # cn-hongkong
  availability_zone = data.alicloud_zones.alicloud-zones-info.zones.0.id
  security_groups   = alicloud_security_group.dev-sec-group.*.id

  # series III
  instance_type              = "ecs.c8y.large"
  system_disk_category       = "cloud_essd"
  system_disk_name           = "ecs-sys-disk-0"
  system_disk_size           = 40
  system_disk_description    = "alicloud ecs system disk 0 "
  system_disk_performance_level  = "PL0"
  description                = "Alicloud ecs develop instance 1"
  private_ip                 = var.instance_info[1].private_ip
  image_id                   = data.alicloud_images.data-dev-ali-img.ids[0]
  instance_name              = var.instance_info[1].instance_name
  vswitch_id                 = alicloud_vswitch.subnet-dev.id
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"
  spot_strategy              = "NoSpot"
  host_name                  = var.instance_info[1].host_name
  password                   = var.hostpassword
  dry_run                    = false 
}

resource "alicloud_instance" "ecs-dev-instance-2" {
  # cn-hongkong
  availability_zone = data.alicloud_zones.alicloud-zones-info.zones.0.id
  security_groups   = alicloud_security_group.dev-sec-group.*.id

  # series III
  instance_type              = "ecs.c8y.large"
  system_disk_category       = "cloud_essd"
  system_disk_name           = "ecs-sys-disk-0"
  system_disk_size           = 40
  system_disk_description    = "alicloud ecs system disk 0 "
  system_disk_performance_level  = "PL0"
  description                = "Alicloud ecs develop instance 2"
  private_ip                 = var.instance_info[2].private_ip
  image_id                   = data.alicloud_images.data-dev-ali-img.ids[0]
  instance_name              = var.instance_info[2].instance_name
  vswitch_id                 = alicloud_vswitch.subnet-dev.id
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"
  spot_strategy              = "NoSpot"
  host_name                  = var.instance_info[2].host_name
  password                   = var.hostpassword
  dry_run                    = false 
}

resource "alicloud_instance" "ecs-dev-instance-3" {
  # cn-hongkong
  availability_zone = data.alicloud_zones.alicloud-zones-info.zones.0.id
  security_groups   = alicloud_security_group.dev-sec-group.*.id

  # series III
  instance_type              = "ecs.c8y.large"
  system_disk_category       = "cloud_essd"
  system_disk_name           = "ecs-sys-disk-0"
  system_disk_size           = 40
  system_disk_description    = "alicloud ecs system disk 0 "
  system_disk_performance_level  = "PL0"
  description                = "Alicloud ecs develop instance 2"
  private_ip                 = var.instance_info[3].private_ip
  image_id                   = data.alicloud_images.data-dev-ali-img.ids[0]
  instance_name              = var.instance_info[3].instance_name
  vswitch_id                 = alicloud_vswitch.subnet-dev.id
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"
  spot_strategy              = "NoSpot"
  host_name                  = var.instance_info[3].host_name
  password                   = var.hostpassword
  dry_run                    = false 
}
