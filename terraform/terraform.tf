terraform {
  backend "s3" {
    bucket         = "testsagar123"  
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
