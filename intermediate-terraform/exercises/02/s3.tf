resource "aws_s3_bucket_object" "user_student_alias_object" {
  bucket  = "rockholla-di-${var.student_alias}"
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias}"
}
