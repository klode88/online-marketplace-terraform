module "networking" {
  source = "./modules/networking"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "alb" {
  source      = "./modules/alb"
  vpc_id      = module.networking.vpc_id
  public_a_id = module.networking.public_a_id
  public_b_id = module.networking.public_b_id
  alb_sg_id   = module.security.alb_sg_id
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source = "./modules/ecs"

  private_a_id                = module.networking.private_a_id
  private_b_id                = module.networking.private_b_id
  ecs_sg_id                   = module.security.ecs_sg_id
  product_tg_arn              = module.alb.product_tg_arn
  cart_tg_arn                 = module.alb.cart_tg_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}

############################################
# Outputs
############################################

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "product_ecr_repository_url" {
  value = module.ecs.product_ecr_repository_url
}

output "cart_ecr_repository_url" {
  value = module.ecs.cart_ecr_repository_url
}