variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC id"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "Existing VPC private subnets"
  type        = list(string)
  default     = []
}
