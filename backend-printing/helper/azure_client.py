"""Azure client library to interact with the Azure services.
"""

import os
from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobClient
from azure.keyvault.secrets import SecretClient
from azure.storage.queue import (
    QueueClient,
    BinaryBase64DecodePolicy,
    BinaryBase64EncodePolicy,
)
from azure.data.tables import TableServiceClient
from helper.constants import KEY_VAULT_URL


class AzureClient:
    def __init__(self):
        self._credential = ManagedIdentityCredential(
            client_id=os.environ["MSI_CLIENT_ID"]
        )

        self.storage_queue_client = QueueClient.from_connection_string(
            conn_str=os.environ["STORAGE_ACCESS_KEY"],
            retry_total=3,
            queue_name=os.environ["STORAGE_QUEUE_NAME"],
            credential=self._credential,
            message_encode_policy=BinaryBase64EncodePolicy(),
            message_decode_policy=BinaryBase64DecodePolicy(),
        )

        self.key_vault_client = SecretClient(
            vault_url=KEY_VAULT_URL % os.environ["KEY_VAULT_NAME"],
            credential=self._credential,
        )

        self.table_service_client = TableServiceClient.from_connection_string(
            conn_str=os.environ["STORAGE_ACCESS_KEY"], retry_total=3
        ).get_table_client(table_name=os.environ["STORAGE_TABLE_NAME"])

    def get_blob_client(self, blob_name):
        """Get the blob client

        Args:
            blob_name (string): blob name

        Returns:
            BlobClient: blob client
        """
        return BlobClient.from_connection_string(
            conn_str=os.environ["STORAGE_ACCESS_KEY"],
            container_name=os.environ["STORAGE_CONTAINER_NAME"],
            blob_name=blob_name,
            credential=self._credential,
        )
