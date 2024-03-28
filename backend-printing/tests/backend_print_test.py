"""Unit tests for the backend_print module.
"""

import os
import requests
import unittest
from unittest.mock import patch, MagicMock, PropertyMock
from helper.backend_print import BackendPrint
from tests.constants import (
    SAP_CONFIG,
    PRINT_QUEUE_ITEM,
    SAP_CONFIG_KV,
    STORAGE_QUEUE_ITEMS,
)


class TestBackendPrint(unittest.TestCase):
    def setUp(self):
        self.backend_print = BackendPrint(logger=MagicMock(), log_tag="Test")
        os.environ["MSI_CLIENT_ID"] = "client_id"
        os.environ["STORAGE_ACCESS_KEY"] = "key"
        os.environ["STORAGE_QUEUE_NAME"] = "queue_name"
        os.environ["STORAGE_TABLE_NAME"] = "table_name"

    @patch("helper.sap_client.SAPPrintClient.get_print_queues")
    @patch("helper.sap_client.SAPPrintClient.find_print_queue")
    @patch("helper.key_vault.AzureClient.__init__")
    @patch("helper.key_vault.KeyVault.set_kv_secrets")
    def test_validation_engine(
        self,
        mock_key_vault_client,
        mock_azure_client,
        mock_find_print_queue,
        mock_get_print_queues,
    ):
        mock_azure_client.return_value = None
        mock_find_print_queue.return_value = True
        mock_get_print_queues.return_value = ["queue1", "queue2"]
        mock_key_vault_client.return_value = True
        sap_config = SAP_CONFIG
        sap_config["sap_environment"] = "DEV"
        response = self.backend_print.validation_engine(SAP_CONFIG)
        self.assertEqual(
            response,
            {"status": "success", "message": "SAP connection validated"},
        )

    @patch("helper.sap_client.SAPPrintClient.get_print_queues")
    @patch("helper.sap_client.SAPPrintClient.find_print_queue")
    @patch("helper.key_vault.AzureClient.__init__")
    @patch("helper.key_vault.KeyVault.set_kv_secrets")
    def test_validation_engine_failure(
        self,
        mock_key_vault_client,
        mock_azure_client,
        mock_find_print_queue,
        mock_get_print_queues,
    ):
        mock_azure_client.return_value = None
        mock_find_print_queue.return_value = True
        mock_get_print_queues.return_value = ["queue1", "queue2"]
        mock_key_vault_client.return_value = True
        response = self.backend_print.validation_engine(SAP_CONFIG)
        self.assertEqual(
            response["status"],
            "error",
        )

    @patch("helper.sap_client.SAPPrintClient.get_print_items_from_queue")
    @patch("helper.storage.AzureClient.__init__")
    @patch("helper.key_vault.AzureClient.__init__")
    @patch("helper.key_vault.KeyVault.get_sap_config_secrets")
    @patch("helper.storage.StorageQueueClient.send_message")
    @patch("helper.storage.TableStorageClient.put_entity")
    def test_fetch_print_items_from_sap(
        self,
        mock_table_put_entity,
        mock_storage_send_message,
        mock_key_vault_get_sap_config_secrets,
        mock_azure_client_kv,
        mock_azure_client_storage,
        mock_get_print_items_from_queue,
    ):
        mock_azure_client_kv.return_value = None
        mock_azure_client_storage.return_value = None
        mock_get_print_items_from_queue.return_value = PRINT_QUEUE_ITEM
        mock_key_vault_get_sap_config_secrets.return_value = SAP_CONFIG_KV
        mock_storage_send_message.return_value = True
        mock_table_put_entity.return_value = True
        response = self.backend_print.fetch_print_items_from_sap()
        self.assertEqual(response, None)

    @patch("helper.storage.StorageQueueClient.receive_messages")
    @patch("helper.storage.StorageQueueClient.delete_message")
    @patch("helper.storage.AzureClient.__init__")
    @patch("helper.key_vault.AzureClient.__init__")
    @patch("helper.universal_print_client.UniversalPrintUsingLogicApp.call_logic_app")
    @patch("helper.storage.TableStorageClient.put_entity")
    @patch(
        "helper.sap_client.SAPPrintClient.fetch_csrf_token_and_update_print_item_status"
    )
    @patch("helper.key_vault.KeyVault.get_sap_config")
    def test_send_print_items_to_universal_print(
        self,
        mock_get_sap_config_kv,
        mock_fetch_csrf_token_and_update_print_item_status,
        mock_put_entity,
        mock_call_logic_app,
        mock_kv_client_storage,
        mock_azure_client_storage,
        mock_delete_message,
        mock_receive_messages,
    ):
        def response():
            res = requests.Response()
            res.status_code = 202
            return res

        mock_get_sap_config_kv.return_value = SAP_CONFIG_KV[0]
        mock_fetch_csrf_token_and_update_print_item_status.return_value = None
        mock_azure_client_storage.return_value = None
        mock_kv_client_storage.return_value = None
        mock_call_logic_app.return_value = response()
        mock_put_entity.return_value = True
        mock_receive_messages.return_value = STORAGE_QUEUE_ITEMS
        mock_delete_message.return_value = True
        response = self.backend_print.send_print_items_to_universal_print()
        self.assertEqual(response, None)

    @patch("helper.universal_print_client.UniversalPrintClient.upload_document")
    def test_upload_document_to_universal_print(self, mock_upload_document):
        mock_upload_document.return_value = True
        response = self.backend_print.upload_document_to_universal_print(
            {"document_name": "name", "document_blob": "blob"}
        )
        self.assertEqual(response, None)
