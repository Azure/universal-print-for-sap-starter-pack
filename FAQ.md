# Frequently Asked Questions

**[🏠Home](README.md)**

**How to deal with SAP ERP disaster recovery regarding the printing integration?**

Consider a snoozed function app in your SAP DR region. [Azure Traffic Manager](https://learn.microsoft.com/azure/app-service/web-sites-traffic-manager) is a good fit to handle the cut-over during the DR process. Furthermore, you may consider more sophisticated reliability options for the involved Azure services.

[Function App](https://learn.microsoft.com/azure/reliability/reliability-functions?tabs=azure-portal)
[Logic App](https://learn.microsoft.com/azure/logic-apps/business-continuity-disaster-recovery-guidance)
[Storage Account](https://learn.microsoft.com/azure/storage/common/storage-disaster-recovery-guidance)
[Key Vault](https://learn.microsoft.com/azure/key-vault/key-vault-disaster-recovery-guidance)

**How to monitor Microsoft Universal Print SAP activities?**

Universal Print has a built-in monitor on the [Azure Portal UI](https://portal.azure.com/?#view/Universal_Print/MainMenuBlade/~/Reports). Print jobs for each printer can be monitored in real-time.

**How to scale Universal Print during high loads?**

Universal Print is a cloud-based service that scales automatically. The service is designed to handle high loads and is managed by Microsoft. See the limits and quotas [here](https://learn.microsoft.com/universal-print/fundamentals/universal-print-limits). Furthermore, see the [Microsoft Graph API throttling guidance](https://learn.microsoft.com/graph/throttling).

The overall integration solution can be scaled individually by adjusting the Azure resources. For example, you can increase the service plan of the Azure Function. See more details [here](https://learn.microsoft.com/azure/azure-functions/functions-scale).

## What else?

Find additional Universal Print FAQs [here](https://learn.microsoft.com/universal-print/fundamentals/universal-print-faqs).
