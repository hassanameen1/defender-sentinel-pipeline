locals {
  tags = {
    project     = "secops-cdr"
    environment = "prod"
    managed_by  = "terraform"
  }
}
module "loganalytics" {
  source              = "./modules/loganalytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

module "sentinel" {
  source            = "./modules/sentinel"
  workspace_id      = module.loganalytics.workspace_id
  subscription_id   = var.subscription_id
  logic_app_id      = module.logic-app.logic_app_id
  resource_group_id = module.loganalytics.resource_group_id
}

module "misconfigs" {
  source              = "./modules/misconfigs"
  location            = var.location
  resource_group_name = module.loganalytics.resource_group_name
  sql_admin_password  = var.sql_admin_password
  tags                = local.tags
  tenant_id           = module.loganalytics.tenant_id
}
module "continuous-export" {
  source              = "./modules/continuous-export"
  location            = var.location
  resource_group_name = var.resource_group_name
  subscription_id     = var.subscription_id
  workspace_id        = module.loganalytics.workspace_id
  tags                = local.tags
}
module "logic-app" {
  source              = "./modules/logic-app"
  location            = var.location
  resource_group_name = module.loganalytics.resource_group_name
  resource_group_id   = module.loganalytics.resource_group_id

}
module "defender-plans" {
  source = "./modules/defender-plans"
}
  