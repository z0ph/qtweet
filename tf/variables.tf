variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "product" {
  default     = "no-product-name"
  description = "Product Name"
}

variable "project" {
  default     = "no-project-name"
  description = "Project Name"
}

variable "description" {
  default     = "empty-project-description"
  description = "Project Description"
}

variable "env" {
  default     = "dev"
  description = "Environment Name"
}

variable "artifacts_bucket" {
  default     = "no-artifact-bucket-defined"
  description = "Artifacts Bucket Name"
}
