variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "node_desired_size" {
  default = 8
  type = number
}
variable "node_maximum_size" {
  default = 4
  type = number
}
variable "node_minimum_size" {
  default = 0
  type = number
}
variable "cluster_name" {
  default = "demo"
  type = string
  description = "AWS EKS CLuster Name"
}
variable "private_1a_cidr" {
  type    = string
  default = "10.0.0.0/19"
}
variable "private_1b_cidr" {
  type    = string
  default = "10.0.32.0/19"
}
variable "public_1a_cidr" {
  type    = string
  default = "10.0.64.0/19"
}
variable "public_1b_cidr" {
  type    = string
  default = "10.0.96.0/19"
}
variable "node_types" {
  type    = list
  default = ["t2.medium"]
}

