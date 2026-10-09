module "image_processor" {
  source = "../../modules/image-processor"

  environment = "prod"
  aws_region  = var.aws_region
  vpc_cidr    = "10.30.0.0/16"
}