data "local_file" "apiconnection" {
    filename            = "${path.module}/schemas/apiconnection.json"
}

data "local_file" "http_trigger" {
    filename            = "${path.module}/schemas/httptrigger.json"
}