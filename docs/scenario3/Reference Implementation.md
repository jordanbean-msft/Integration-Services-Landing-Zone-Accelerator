# Reference Implementation

All code and templates for the reference implementation (including the
_Deploy to Azure_ sample) can be found here:

<https://github.com/Azure/Integration-Services-Landing-Zone-Accelerator/tree/main/src/infra/scenario3>

Following the guidance in the earlier sections of this guide, we have
prepared a series of deployment templates, which will deploy all the
resources needed for an Enterprise-ready AIS installation, following the
recommended practices (e.g., placing resources inside a Virtual Network,
linking to Monitoring solutions). Once deployed, all a customer needs to
do is upload their own code/workflows/files to start using this
environment.

**Please note**: most of these resources require a Premium SKU to be
used with Virtual Networking. Deploying the example resources below will
start incurring costs based on those Premium SKUs, from the point at
which they are deployed.

The reference implementation consists of a series of Terraform templates.

The reference implementation consists of the following resources:

<img src="../../.img/scenario3/physical-architecture.drawio.png" style="width:5in;height:3.73958in"
alt="This diagram shows the resources that are deployed as part of the Deploy to Azure template, and which ones are in a Virtual Network. " />

The Terraform templates deploy the following resources:

- Virtual Network

  - This script assumes you already have a Virtual Network deployed by your Cloud Operations team, and
    will deploy resources into that VNet

  - This script also assumes you already have a mechanism for creating the A records needed to resolve
    private endpoints in your DNS solution (such as Deploy-If-Not-Exists (DINE) policies)

- Storage Account

- Log Analytics workspace

- Application Insights

  - Connected to the Log Analytics workspace

- Key Vault

- API Management

  - Uses Premium SKU

  - Connected to Application Insights

  - Diagnostic Setting to log to Log Analytics workspace

  - Deploy into VNet (Internal mode)

- Service Bus

  - Uses Premium SKU

  - Disables Public Network access

  - Creates Private Endpoint into VNet

  - Sets “Allow trusted Microsoft services to bypass this firewall” to
    true

- App Service Plans

  - Logic App (Standard) plan using I1v2 SKU

  - Azure Function plan using I1v2 SKU

- Logic App (Standard)

  - Uses I1v2 App Service Plan

  - Uses storage account

  - Connected to Application Insights

  - Diagnostic Setting to log to Log Analytics workspace

  - Deployed into VNet

- Function App

  - Uses I1v2 App Service Plan

  - Uses storage account

  - Connected to Application Insights

  - Diagnostic Setting to log to Log Analytics workspace

  - Deployed into VNet

- App Configuration

  - Deployed into VNet

- API Center

  - Deployed into VNet

Deployment of these resources can be done in a single step, using the
main Terraform template.

Update the variables in the `main.tfvars.json` file to match your
environment, and then run the following commands:

```bash
terraform init
terraform plan -var-file="main.tfvars.json" -out="plan.out"
terraform apply "plan.out"
```
