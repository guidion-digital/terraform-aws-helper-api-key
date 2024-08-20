variable "name" {
  description = "Used for naming"
  type        = string
}

variable "principals" {
  description = "Map of {type to [IAM ARNs]} of the role to share the API keys with"
  type        = map(list(string))
  default     = {}
}

variable "v2_api" {
  description = "Usage quotas are not applicable for v2 APIs, so this disables them"
  type        = bool
  default     = false
}

variable "quota_settings" {
  description = "Number of requests clients can make in a period"

  type = object({
    limit  = optional(number), # Maximum number of requests that can be made in a given time period
    offset = optional(number), # Number of requests subtracted from the given limit in the initial time period
    period = optional(string)  # Time period in which the limit applies. Valid values are "DAY", "WEEK" or "MONTH"
  })

  default = null
}

variable "throttle_settings" {
  description = "Rate at which clients can make requests"

  type = object({
    burst_limit = optional(number), # The API request burst limit, the maximum rate limit over a time ranging from one to a few seconds, depending upon whether the underlying token bucket is at its full capacity
    rate_limit  = optional(number)  # The API request steady-state rate limit
  })

  default = null
}

variable "api_id" {
  description = "ID of the API Gateway to attach usage plan to"
  type        = string
}

variable "stages" {
  description = "Object of stages and optional throttling settings"
  type = map(object({
    throttle = optional(object({
      path        = string
      burst_limit = optional(number)
      rate_limit  = optional(number)
    }), { path = null })
  }))

  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

