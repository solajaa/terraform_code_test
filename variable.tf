variable vpc_cidr {}
variable vpc_cidr2 {}
variable env_prefix {}
variable region {}
variable vpc_id {}
variable ami {}
variable instance_type {}
variable ec2_count {}
#variable web_tags {}
variable "web_tags" {
  type = map(string)
  default = {
    Name = "Webserver"
  }
}
variable app_s3 {}
variable my_ip {}
variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "common_tags" {}

variable "username" {}
