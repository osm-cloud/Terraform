resource "aws_kinesis_stream" "test_stream" {
  name             = "<env>-kds"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED" #PROVISIONED, ON_DEMAND
  }

  tags = {
    Environment = "<env>-kds"
  }
}