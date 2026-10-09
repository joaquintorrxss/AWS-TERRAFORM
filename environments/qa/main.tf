module "image_processor" {
  source = "../../modules/image-processor"

  environment = "qa"
  aws_region  = var.aws_region
  vpc_cidr    = "10.20.0.0/16"
}