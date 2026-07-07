output "alicloud_zones_output" {
  value = data.alicloud_zones.alicloud-zones-info
}

output "op-dev-ali-img" {
  value = data.alicloud_images.data-dev-ali-img.ids[0]
}