module "network" {
  source = "./module/vpc"

  region   = "us-east-1"
  vpc_cidr = "10.30.0.0/16"


  public_cidr = [
    { cidr = "10.30.1.0/24", az = "us-east-1a" },
    { cidr = "10.30.2.0/24", az = "us-east-1b" }
  ]

  private_cidr = [
    { cidr = "10.30.3.0/24", az = "us-east-1a" },
    { cidr = "10.30.4.0/24", az = "us-east-1b" },
    { cidr = "10.30.5.0/24", az = "us-east-1a" },
    { cidr = "10.30.6.0/24", az = "us-east-1b" },
    { cidr = "10.30.7.0/24", az = "us-east-1a" },
    { cidr = "10.30.8.0/24", az = "us-east-1b" }
  ]


}

output "network_id" {
  value = module.network.vpc_id
}

module "security_group" {
  source = "./module/security_group"

  sg_name             = "3-tier-security-group"
  vpc_id              = module.network.vpc_id
  ingress_from_port   = 0
  ingress_to_port     = 0
  ingress_protocol    = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port    = 0
  egress_to_port      = 0
  egress_protocol     = "-1"
  egress_cidr_blocks  = ["0.0.0.0/0"]

}

output "security_group_id" {
  value = module.security_group.security_gp_id

}


module "database" {
  source = "./module/RDS"

  db_subnet_group_name  = "three-tier-subnet-group"
  db_subnets            = [module.network.private_subnets[4], module.network.private_subnets[5]]
  db_identifier         = "book-store-app"
  db_engine             = "mysql"
  db_storage            = 30
  db_storage_type       = "gp3"
  db_instance_class     = "db.t3.micro"
  db_name               = "test"
  db_username           = "admin"
  db_password           = "Somesh12345"
  db_security_group_ids = [module.security_group.security_gp_id]

}

output "db_endpoint" {
  value = module.database.db_endpoint

}


module "load_balancer" {
  source           = "./module/loadbalancer"
  frontend_lb_name = "frontend-lb"
  backend_lb_name  = "backend-lb"
  vpc_id           = module.network.vpc_id
  frontend_tg_name = "frontend-tg"
  backend_tg_name  = "backend-tg"
  public_subnets   = [module.network.public_subnets[0], module.network.public_subnets[1]]
  security_groups  = [module.security_group.security_gp_id]
  certificate_arn  = module.acm.acm_certificate_arn
}

output "frontend_lb_dns" {
  value = module.load_balancer.frontend_lb_dns

}

output "backend_lb_dns" {
  value = module.load_balancer.backend_lb_dns

}

module "launch_template" {
  source             = "./module/lanuch_template"
  frontend_LT_name   = "frontend-launch-template"
  backend_LT_name    = "backend-launch-template"
  key_name           = "ansible"
  instance_type      = "t3.medium"
  frontend_image_id  = "ami-0b43b979fd80c51bb"
  backend_image_id   = "ami-0580db2002f7edccb"
  security_group_id  = [module.security_group.security_gp_id]
  frontend_user_data = "frontend.sh"
  backend_user_data  = "backend.sh"

}

output "frontend_lt_id" {
  value = module.launch_template.frontend_lt_id

}

output "backend_lt_id" {
  value = module.launch_template.backend_lt_id

}

module "autoscaling_group" {
  source = "./module/autoscaling_grouping"

  frontend_asg_name          = "frontend_asg"
  frontend_min_size          = 1
  frontend_max_size          = 1
  frontend_desired_capacity  = 1
  frontend_asg_subnets       = [module.network.private_subnets[0], module.network.private_subnets[1]]
  frontend_target_group_arns = [module.load_balancer.frontend_target_group_arns]
  frontend_asg_lt            = module.launch_template.frontend_lt_id

  backend_asg_name          = "backend_asg"
  backend_min_size          = 1
  backend_max_size          = 1
  backend_desired_capacity  = 1
  backend_asg_subnets       = [module.network.private_subnets[2], module.network.private_subnets[3]]
  backend_target_group_arns = [module.load_balancer.backend_target_group_arns]
  backend_asg_lt            = module.launch_template.backend_lt_id


}

output "frontend_asg" {
  value = module.autoscaling_group.frontend_asg_id
}

output "backend_asg" {
  value = module.autoscaling_group.backend_asg_id
}


module "jump_server" {
  source = "./module/bastion_host"

  ami_id          = "ami-0d27e0fb3bac4d724"
  key_name        = "ansible"
  instance_type   = "t3.micro"
  security_groups = [module.security_group.security_gp_id]
  public_sn       = module.network.public_subnets[0]

}

output "jump_server_public_ip" {
  value = module.jump_server.bastion_public_ip

}


module "route53" {
  source = "./module/route53"

  vpc_id                  = module.network.vpc_id
  rds_endpoint            = module.database.db_address
  public_zone_name        = "rebel7781.xyz"
  alb_dns_backend_record  = "api.rebel7781.xyz"
  alb_backend_dns_name    = module.load_balancer.backend_lb_dns
  alb_backend_zone_id     = module.load_balancer.backend_lb_zone_id
  alb_dns_frontend_record = "somu.rebel7781.xyz"
  alb_front_dns_name      = module.load_balancer.frontend_lb_dns
  alb_front_zone_id       = module.load_balancer.frontend_lb_zone_id

}

module "acm" {
  source = "./module/acm"

  domain_name = "rebel7781.xyz"
  san_name    = ["*.rebel7781.xyz"]
}






