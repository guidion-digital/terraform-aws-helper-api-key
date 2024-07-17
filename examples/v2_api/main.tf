module "api_keys" {
  source = "../../"

  name   = "app-x"
  api_id = "foobar"
  v2_api = true

  tags = { "foo" = "bar" }
}
