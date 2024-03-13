variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
variable "aws_access_key" {
    type = string
    description = "AWS Access key"
}

variable "aws_secret_key" {
    type = string
    description = "AWS Secret Key"
}
