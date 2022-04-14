variable "function_name"{
    type = string
    default = "eventbridge-lambda"
}

variable "cron"{
    type = string
    default = "0 12,16,20 * * ? *"
}