variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "project" {
  default = "no-project-name"
  description = "Project Name"
}

variable "description" {
  default = "empty-project-description"
  description = "Project Description"
}

variable "env" {
  default = "dev"
  description = "Environment Name"
}

variable "artifacts_bucket" {
  default = "no-artifact-bucket-defined"
  description = "Artifacts Bucket Name"
}

variable "layer_arn" {
  default = "arn:aws:lambda:eu-west-1:567589703415:layer:boto3-layer:15"
}
