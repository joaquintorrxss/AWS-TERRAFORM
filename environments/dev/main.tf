module "image_processor" {
  source = "../../modules/image-processor"

  environment = "dev"
  aws_region  = var.aws_region
  vpc_cidr    = "10.10.0.0/16"
}