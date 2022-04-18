variable "function_name"{
    type = string
    default = "eventbridge-lambda"
}

variable "cron"{
    type = list
    default = ["0 12,16,20 * * ? *","0 22 ? * TUE-SUN *", "0 8 ? * MON *"]
}