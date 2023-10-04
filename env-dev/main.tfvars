env = "dev"

tags = {
  company_name  = "XTZ Tech"
  business      = "ecommerce"
  business_unit = "retail"
  cost_center   = "322"
  project_name  = "roboshop"
}

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    subnets    = {
      web    = { cidr_block = ["10.0.0.0/24", "10.0.1.0/24"] }
      app    = { cidr_block = ["10.0.2.0/24", "10.0.3.0/24"] }
      db     = { cidr_block = ["10.0.4.0/24", "10.0.5.0/24"] }
      public = { cidr_block = ["10.0.6.0/24", "10.0.7.0/24"] }
    }
  }
}

default_vpc_id = "vpc-07e965f3c5e0cef0a"
default_vpc_rt = "rtb-0536cf0e3912e0a5a"
allow_ssh_cidr = ["172.31.29.210/32"]
zone_id        = "Z070672135BYB8H2ZSHPN"
kms_key_id     = "80393f26-f6cd-4ccf-8282-eec198269898"
kms_key_arn    = "arn:aws:kms:us-east-1:178724175855:key/80393f26-f6cd-4ccf-8282-eec198269898"

rabbitmq = {
  main = {
    instance_type = "t3.small"
    component     = "rabbitmq"
  }
}

rds = {
  main = {
    component      = "rds"
    engine         = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.3"
    db_name        = "dummy"
    instance_count = 1
    instance_class = "db.t3.small"
  }
}

documentdb = {
  main = {
    component = "docdb"

  }
}

elasticache = {
  main = {
    component = "elasticache"
    engine = "redis"
    engine_version = "6.2"
    replicas_per_node_group = 1
    num_node_groups = 1




  }
}

#variable "engine" {}
#variable "node_type" {}
#variable "engine_version" {}
#variable "port" {
#  default = 6379
#}
#variable "vpc_id" {}
#variable "num_node_groups" {}
#variable "replicas_per_node_group" {}