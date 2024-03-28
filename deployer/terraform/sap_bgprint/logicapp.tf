resource "azurerm_logic_app_workflow" "logic_app" {
    name                = format("%s%s-logicapp", lower(var.environment), lower(var.location))
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    workflow_version    =  "1.0.0.0"
    workflow_schema     = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    parameters          = {
        "$connections"  = jsonencode({
            "${azurerm_resource_group_template_deployment.apiconnection.name}" = {
                connectionId    = "${jsondecode(azurerm_resource_group_template_deployment.apiconnection.output_content).apiConnectionId.value}"
                connectionName  = "${azurerm_resource_group_template_deployment.apiconnection.name}"
                id              = "${azapi_resource.custom_connector.id}"
            }
        })
    }
    workflow_parameters     = {
        "$connections"      = jsonencode({
            defaultValue    = {}
            type            = "Object"
        })
    }
    depends_on              = [ azurerm_resource_group_template_deployment.apiconnection ]
}

resource "azurerm_logic_app_trigger_http_request" "logic_app_trigger" {
    name                    = "FunctionAppCallee"
    logic_app_id            = azurerm_logic_app_workflow.logic_app.id 
    method                  = "POST"
    schema                  = data.local_file.http_trigger.content
}

resource "azurerm_logic_app_action_custom" "logic_app_action_get_printer_share" {
    name                = "GetPrinterShare"
    logic_app_id        = azurerm_logic_app_workflow.logic_app.id
    body                = <<BODY
    {
        "inputs": {
            "headers": {
                "Content-Type": "application/json"
            },
            "host": {
                "connection": {
                    "name": "@parameters('$connections')['${azurerm_resource_group_template_deployment.apiconnection.name}']['connectionId']"
                }
            },
            "method": "get",
            "path": "/v1.0/print/shares/@{encodeURIComponent(triggerBody()?['printer_share_id'])}"
        },
        "runAfter": {},
        "type": "ApiConnection"
    }
    BODY
}

resource "azurerm_logic_app_action_custom" "logic_app_action_create_print_job" {
    name                = "CreatePrintJob"
    logic_app_id        = azurerm_logic_app_workflow.logic_app.id
    body                = <<BODY
    {
        "inputs": {
            "headers": {
                "Content-Type": "application/json"
            },
            "body": {
                "configuration": {
                    "copies": 1,
                    "dpi": "@body('${azurerm_logic_app_action_custom.logic_app_action_get_printer_share.name}')?['defaults']?['dpi']",
                    "duplexMode": "oneSided",
                    "fitPdfToPage": false,
                    "mediaType": "stationery",
                    "pagesPerSheet": "@body('${azurerm_logic_app_action_custom.logic_app_action_get_printer_share.name}')?['defaults']?['pagesPerSheet']",
                    "quality": "medium",
                    "scaling": "shrinkToFit"
                }
            },
            "host": {
                "connection": {
                    "name": "@parameters('$connections')['${azurerm_resource_group_template_deployment.apiconnection.name}']['connectionId']"
                }
            },
            "method": "post",
            "path": "/v1.0/print/shares/@{encodeURIComponent(triggerBody()?['printer_share_id'])}/jobs"
        },
        "runAfter": {
            "${azurerm_logic_app_action_custom.logic_app_action_get_printer_share.name}": [
                "Succeeded"
            ]
        },
        "type": "ApiConnection"
    }
    BODY
}

resource "azurerm_logic_app_action_custom" "logic_app_action_create_upload_session_for_printer_share" {
    name                = "CreateUploadSessionForPrinterShareLoop"
    logic_app_id        = azurerm_logic_app_workflow.logic_app.id
    body                = <<BODY
    {
        "actions": {
            "CreateUploadSessionForPrinterShare": {
                "inputs": {
                    "body": {
                        "properties": {
                            "contentType": "@triggerBody()?['document_content_type']",
                            "documentName": "@triggerBody()?['document_name']",
                            "size": "@triggerBody()?['document_file_size']"
                        }
                    },
                    "host": {
                        "connection": {
                            "name": "@parameters('$connections')['${azurerm_resource_group_template_deployment.apiconnection.name}']['connectionId']"
                        }
                    },
                    "method": "post",
                    "path": "/v1.0/print/shares/@{encodeURIComponent(triggerBody()?['printer_share_id'])}/jobs/@{encodeURIComponent(body('${azurerm_logic_app_action_custom.logic_app_action_create_print_job.name}')?['id'])}/documents/@{encodeURIComponent(items('CreateUploadSessionForPrinterShareLoop')?['id'])}/createUploadSession"
                },
                "runAfter": {},
                "type": "ApiConnection"
            },
            "UploadDocumentToUP": {
                        "inputs": {
                            "body": {
                                "document_blob": "@{triggerBody()?['document_blob']}",
                                "document_file_size": "@{triggerBody()?['document_file_size']}",
                                "document_name": "@{triggerBody()?['document_name']}",
                                "next_expected_range": "@{body('CreateUploadSessionForPrinterShare')?['nextExpectedRanges']}",
                                "upload_url": "@{body('CreateUploadSessionForPrinterShare')?['uploadUrl']}"
                            },
                            "function": {
                                "id": "${azurerm_linux_function_app.function_app.id}/functions/uploaddocumenttoup"
                            },
                            "headers": {
                                "Content-Type": "application/json"
                            },
                            "method": "POST"
                        },
                        "runAfter": {
                            "CreateUploadSessionForPrinterShare": [
                                "Succeeded"
                            ]
                        },
                        "type": "Function"
                    }
        },
        "foreach": "@body('${azurerm_logic_app_action_custom.logic_app_action_create_print_job.name}')?['documents']",
        "runAfter": {
            "${azurerm_logic_app_action_custom.logic_app_action_create_print_job.name}": [
                "Succeeded"
            ]
        },
        "type": "Foreach"
    }
    BODY
}

resource "azurerm_logic_app_action_custom" "logic_app_action_start_print_job" {
    name                = "StartPrintJob"
    logic_app_id        = azurerm_logic_app_workflow.logic_app.id
    body                = <<BODY
    {
        "inputs": {
            "headers": {
                "Content-Type": "application/json"
            },
            "host": {
                "connection": {
                    "name": "@parameters('$connections')['${azurerm_resource_group_template_deployment.apiconnection.name}']['connectionId']"
                }
            },
            "method": "post",
            "path": "/v1.0/print/shares/@{encodeURIComponent(triggerBody()?['printer_share_id'])}/jobs/@{encodeURIComponent(body('${azurerm_logic_app_action_custom.logic_app_action_create_print_job.name}')?['id'])}/start"
        },
        "runAfter": {
            "${azurerm_logic_app_action_custom.logic_app_action_create_upload_session_for_printer_share.name}": [
                "Succeeded"
            ]
        },
        "type": "ApiConnection"
    }
    BODY
}
