module "demo-vpc" {
    source = "./VPC"
    cidr_private_subnet = "10.0.64.0/18"
    cidr_public_subnet = "10.0.0.0/22"
    vpc_name = "DEMO-VPC"
    us_availability_zone = "us-east-1a"
}