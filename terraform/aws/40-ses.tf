resource "aws_sesv2_email_identity" "email_notifications" {
    count = length(local.aws.ses)
 
    email_identity = local.aws.ses[count.index]
}