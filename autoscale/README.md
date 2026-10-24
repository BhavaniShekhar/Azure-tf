# Linux App Service autoscale module

The reusable module in [`modules/app_service`](./modules/app_service) creates an
Azure resource group, a Linux App Service Plan, a Linux Web App, workspace-based
Application Insights, a Log Analytics workspace, and CPU-based autoscaling. The
root configuration is an example caller that deploys the sample in `app/`.

The example configures an S1 App Service Plan with this autoscale profile:

| Setting | Value |
| --- | --- |
| Default / minimum / maximum instances | 1 / 1 / 3 |
| Scale out | Average CPU above 70% for 10 minutes; add 1 instance |
| Scale in | Average CPU below 30% for 20 minutes; remove 1 instance |

## Reuse the module

Add a module block for each independent deployment. Give each instance a
different resource group and name prefixes; leave `resource_suffix` unset to
generate a suffix automatically:

```hcl
module "production_app" {
  source = "./modules/app_service"

  location               = "southindia"
  resource_group_name    = "rg-production-app"
  app_source_dir         = "${path.root}/app"
  app_name_prefix        = "production"
  web_app_name_prefix    = "production-web"
  service_plan_sku       = "S1"
  min_instance_count     = 1
  default_instance_count = 1
  max_instance_count     = 3
}
```

The module exports the Web App URL and name, Application Insights and Log
Analytics names, and App Service Plan ID. Each instance packages the supplied
app source directory as a ZIP for deployment. Use distinct resource groups and
name prefixes for separate module instances.

Application Insights uses the Log Analytics workspace for request and
dependency telemetry. To inspect scale activity, open the App Service Plan's
**Metrics** in the Azure portal and view **CPU Percentage**; review scale
operations under **Autoscale** or the resource group's **Activity log**.

This example uses the App Service public endpoint directly; it does not create
Azure Front Door or a separate load balancer. Standard S1 App Service Plan
instances incur ongoing Azure charges, so run `terraform destroy` when the
environment is no longer needed.

## Deploy the example

Prerequisites: Terraform 1.5+, Azure CLI, and an Azure subscription with
permission to create these resources. Sign in and select the intended
subscription before applying:

```powershell
az login
az account set --subscription "<subscription-id>"
terraform init
terraform plan
terraform apply
```

The example pins the existing deployment's resource suffix (`9equss`) so it can
continue managing resources already created by this root configuration. For a
new deployment, set `resource_suffix = null` in a `.tfvars` file to generate a
fresh suffix. The module itself defaults to generating one.

The `/health` endpoint is used by App Service health checks; `/work` runs a
short CPU workload that can help exercise the autoscale rule. Autoscaling
requires sustained CPU averages over the configured time windows.

The root configuration includes `moved` blocks for the previous resource
addresses. They preserve state for resources Terraform already tracked. In the
current deployment, the App Service Plan, Log Analytics workspace, Application
Insights component, and autoscale setting exist in Azure but may not be in the
local Terraform state. Import those existing resources at their new module
addresses before applying:

```powershell
$subscriptionId = (az account show --query id --output tsv)
terraform import module.app_service.azurerm_service_plan.app "/subscriptions/$subscriptionId/resourceGroups/rg-appservice-autoscale-demo/providers/Microsoft.Web/serverFarms/asp-appservice-9equss"
terraform import module.app_service.azurerm_log_analytics_workspace.app "/subscriptions/$subscriptionId/resourceGroups/rg-appservice-autoscale-demo/providers/Microsoft.OperationalInsights/workspaces/law-appservice-9equss"
terraform import module.app_service.azurerm_application_insights.app "/subscriptions/$subscriptionId/resourceGroups/rg-appservice-autoscale-demo/providers/Microsoft.Insights/components/appi-appservice-9equss"
terraform import module.app_service.azurerm_monitor_autoscale_setting.app "/subscriptions/$subscriptionId/resourceGroups/rg-appservice-autoscale-demo/providers/Microsoft.Insights/autoscaleSettings/autoscale-appservice-9equss"
```

The resource group is already tracked and will be moved automatically. The Web
App is not present in Azure yet, so Terraform will create it. Review
`terraform plan` after importing; do not remove state or destroy Azure resources
to complete this refactor.

## Clean up

```powershell
terraform destroy
```
# Azure-tf
