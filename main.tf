locals {
  secret_name    = "api-keys/${var.name}"
  quota_settings = var.quota_settings == null ? {} : var.quota_settings
}

resource "aws_api_gateway_api_key" "this" {
  name = var.name
  tags = var.tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.v2_api ? 0 : 1

  name = "${var.name}-${aws_api_gateway_api_key.this.name}"

  dynamic "api_stages" {
    for_each = var.stages

    content {
      stage  = api_stages.key
      api_id = var.api_id

      dynamic "throttle" {
        for_each = api_stages.value.throttle.path != null ? [api_stages.value.throttle] : []

        content {
          path        = throttle.value.path
          burst_limit = throttle.value.burst_limit
          rate_limit  = throttle.value.rate_limit
        }
      }
    }
  }

  dynamic "quota_settings" {
    for_each = var.quota_settings == null ? {} : { enabled = "true" }

    content {
      limit  = var.quota_settings.limit
      offset = var.quota_settings.offset
      period = var.quota_settings.period
    }
  }

  dynamic "throttle_settings" {
    for_each = var.throttle_settings == null ? {} : { enabled = "true" }

    content {
      burst_limit = var.throttle_settings.burst_limit
      rate_limit  = var.throttle_settings.rate_limit
    }
  }

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count = var.v2_api ? 0 : 1

  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = one(aws_api_gateway_usage_plan.this).id
}

resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_name
  recovery_window_in_days = 0
  policy                  = length(var.principals) == 0 ? "{}" : data.aws_iam_policy_document.this.json
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = aws_api_gateway_api_key.this.value
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
    # N.B. '*' here does not mean all secrets, only this secret

    dynamic "principals" {
      for_each = var.principals

      content {
        type        = principals.key
        identifiers = principals.value
      }
    }
  }
}
