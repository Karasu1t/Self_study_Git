# ------------------------------------
# Terraform Cofiguration
# ------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

# ------------------------------------
# Variables
# ------------------------------------
variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "address" {
  type = string
}

variable "environment" {
  type = string
}