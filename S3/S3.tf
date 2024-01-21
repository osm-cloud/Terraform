#S3
resource "aws_s3_bucket" "s3" {
  bucket = "<Bucket Name>"

  tags = {
    Name = "<Bucket Name>"
  }
}

resource "aws_s3_object" "object1" {
  bucket = aws_s3_bucket.s3.id
  key = "<file name>"
  source = "<path>"
}