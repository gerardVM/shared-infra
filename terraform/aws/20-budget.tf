resource "aws_budgets_budget" "cheap" {
    count            = length(local.aws.budgets)

    budget_type       = "COST"
    limit_amount      = split(" ", local.aws.budgets[count.index].limit)[0]
    limit_unit        = split(" ", local.aws.budgets[count.index].limit)[1]
    name              = local.aws.budgets[count.index].name
    time_period_end   = "2087-06-15_00:00"
    time_period_start = "2022-05-01_00:00"
    time_unit         = "MONTHLY"

    cost_types {
        include_credit             = false
        include_discount           = true
        include_other_subscription = true
        include_recurring          = true
        include_refund             = false
        include_subscription       = true
        include_support            = true
        include_tax                = true
        include_upfront            = true
        use_amortized              = false
        use_blended                = false
    }

    notification {
        comparison_operator        = "GREATER_THAN" 
        notification_type          = "ACTUAL" 
        subscriber_email_addresses = [local.aws.budgets[count.index].notify]
        subscriber_sns_topic_arns  = [] 
        threshold                  = 80 
        threshold_type             = "PERCENTAGE" 
    }

    notification {
        comparison_operator        = "GREATER_THAN" 
        notification_type          = "FORECASTED" 
        subscriber_email_addresses = [local.aws.budgets[count.index].notify]
        subscriber_sns_topic_arns  = [] 
        threshold                  = 60 
        threshold_type             = "PERCENTAGE" 
    }
}