resource "aws_sqs_queue" "queue" {

  name                      = "s3-event-notification-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

 policy = <<POLICY
{
   "Version": "2012-10-17",
   "Id": "Queue1_Policy_UUID",
   "Statement": [{
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-notification-queue",
      "Condition" : {
         "ArnEquals" : {
            "aws:SourceArn":"${aws_s3_bucket.bucket.arn}"
         }
      }
   }]
}
POLICY

  tags = {
    Environment = "production"
  }
}

resource "random_string" "id"{
    length = "5"
    special = false
    upper = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "mybucket-s3-g2-${random_string.id.result}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    count = "${var.event ? 1 : 0}"
    bucket = "${aws_s3_bucket.bucket.id}" 
    queue {
        queue_arn = "${aws_sqs_queue.queue.arn}"
        events = ["s3:ObjectCreated:Put"]
    }
}
