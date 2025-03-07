variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type for web app and MySQL"
  type        = string
  default     = "t2.micro"
}

variable "ssh_username" {
  description = "SSH username for EC2 instances"
  type        = string
  default     = "ubuntu"
}

variable "webapp_ami_id" {
  description = "AMI ID for the WebApp instance"
  type        = string
  default     = "ami-xxxxxxx"
}

variable "mysql_ami_id" {
  description = "AMI ID for the MySQL instance"
  type        = string
  default     = "ami-xxxxxxx"
}

variable "instance_volume_size" {
  description = "Size of the volume attached to the EC2 instance (in GB)"
  type        = number
  default     = 20
}

variable "instance_volume_type" {
  description = "Type of the volume attached to the EC2 instance"
  type        = string
  default     = "gp2"
}

variable "subnet_id_public" {
  description = "Public subnet"
  type        = string
  default     = "subnet-077303a3470268153"
}

variable "subnet_id_private" {
  description = "Private subnet"
  type        = string
  default     = "subnet-0046aa2eac30c0aa7"
}

variable "vpc_id" {
  description = "VPC"
  type        = string
  default     = "vpc-033a734abfa2681a9"
}

variable "webapp_security_group" {
  description = "WebApp Security Group"
  type        = string
  default     = "sg-0fcc04bbde718f723"
}

variable "mysql_security_group" {
  description = "MySQL Security Group"
  type        = string
  default     = "sg-0da98cee4c6cb18d8"
}

variable "mysql_port" {
  description = "The port MySQL is running on"
  type        = number
  default     = 3306
}

variable "database_username" {
  description = "Database username"
  type        = string
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "webapp_secret_key" {
  description = "Web app secret key"
  type        = string
  sensitive   = true
}
