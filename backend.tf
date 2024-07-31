terraform {
    backend "s3" {
        bucket = "s3h"
        key = "TERRA-07-31.terraform.tfstate"
        region = "ap-northeast-1"
       dynamodb_table = "terraform-state-lock-dynamo" # DynamoDB table used for state locking, note: first run day-4-statefile-s3
        encrypt        = true  # Ensures the state is encrypted at rest in S3.
    }

}
