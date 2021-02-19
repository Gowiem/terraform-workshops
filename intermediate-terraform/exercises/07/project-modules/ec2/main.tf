resource "aws_key_pair" "project" {
  count      = length(var.keys)
  key_name   = "${var.unique_prefix}-${var.keys[count.index].name}-${uuid()}"
  public_key = var.keys[count.index].public_key
}
