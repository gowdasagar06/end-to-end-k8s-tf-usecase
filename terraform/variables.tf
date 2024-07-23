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

variable "ingress_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:ap-south-1:654654515013:loadbalancer/net/ab9ae628c3ed949819141d3a57593554/dc035b11716a1853"
}

variable "ingress_name" {
  type    = string
  default = "ab9ae628c3ed949819141d3a57593554"
}

variable "grafana_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:ap-south-1:654654515013:loadbalancer/net/a285fbbb3031144e188c11cdb49988d7/2c67c27ec4e457d8"
}

variable "grafana_name" {
  type    = string
  default = "a285fbbb3031144e188c11cdb49988d7"
}

variable "prometheus_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:ap-south-1:654654515013:loadbalancer/net/a7fef636a9e2144eb9a1ba300aeaf50a/bba523c1a1b0238f"
}

variable "prometheus_name" {
  type    = string
  default = "a7fef636a9e2144eb9a1ba300aeaf50a"
}

variable "ingress_record" {
  type    = string
  default = "app.gowdasagar.online"
}
variable "grafana_record" {
  type    = string
  default = "grafana.gowdasagar.online"
}
variable "prometheus_record" {
  type    = string
  default = "prometheus.gowdasagar.online"
}

