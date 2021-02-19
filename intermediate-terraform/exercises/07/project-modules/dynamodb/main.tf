resource "aws_dynamodb_table" "project" {
  name           = "${var.unique_prefix}_${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "project" {
  count = length(var.table_items)
  table_name = aws_dynamodb_table.project.name
  hash_key   = aws_dynamodb_table.project.hash_key
  range_key  = aws_dynamodb_table.project.range_key

  item = <<ITEM
{
  "${var.hash_key}": {"S": "${var.table_items[count.index].hash_key_value}"},
  "${var.range_key}": {"S": "${var.table_items[count.index].range_key_value}"}
}
ITEM
}
