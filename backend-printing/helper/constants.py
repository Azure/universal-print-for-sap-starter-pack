"""Constants for the project"""

BASE_URL = "%s/sap/opu/odata/sap/API_CLOUD_PRINT_PULL_SRV/"
KEY_VAULT_URL = "https://%s.vault.azure.net/"

# API methods in the API_CLOUD_PRINT_PULL_SRV
GET_PRINT_QUEUES = "Get_PrintQueuesOfUser()"
GET_NUMBER_OF_PRINT_ITEMS = "Get_NumberOfQItemsExt"
GET_N_NEXT_PRINT_ITEMS = "Get_Next_QItemsExt"
GET_NEXT_PRINT_ITEM = "Get_RetrieveNextQueueItem"

SAP_CONFIG_KEY_VAULT_KEY = "BGPRINT-%s-%s"

AZURE_USER_KEY_VAULT_KEY = "USER-TOKEN-%s"

MAX_ITEMS_TO_FETCH = 10

AUTHORIZATION_SCOPE = ["https://graph.microsoft.com/.default"]

DOCUMENT_CONTENT_TYPE = "application/pdf"

MESSAGE_EXPIRY_TIME = 3600

NUMBER_OF_THREADS = 3

ITEM_STATUS = "[{\"ITEM_ID\":\"%s\",\"STATUS\": \"%s\"}]"