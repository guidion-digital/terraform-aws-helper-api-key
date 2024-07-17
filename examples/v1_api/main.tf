module "api_keys" {
  source = "../../"

  name   = "app-x"
  api_id = "foobar"

  stages = {
    "preprod" = {}

    "live" = {
      throttle = {
        path        = "foo/GET"
        burst_limit = 100
        rate_limit  = 200
      }
    }
  }

  quota_settings = {
    limit  = 10
    offset = 2
    period = "DAY"
  }

  throttle_settings = {
    burst_limit = 20
    rate_limit  = 300
  }

  tags = { "foo" = "bar" }
}
