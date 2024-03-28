import json
from azure.keyvault.secrets import SecretProperties, KeyVaultSecret
from azure.core.paging import ItemPaged
import datetime
from azure.storage.queue import QueueMessage

SAP_CONFIG = {
    "sap_sid": "sid",
    "sap_user": "user",
    "sap_password": "password",
    "sap_hostname": "localhost",
    "sap_print_queues": [
        {"queue_name": "queue1", "print_share_id": "printer1"},
        {"queue_name": "queue2", "print_share_id": "printer2"},
    ],
}
SAP_CONFIG_KV = [
    KeyVaultSecret(
        value='{"sap_sid": "TT1", "sap_environment": "DEV", "sap_user": "DEVANSH", "sap_password": "Spartan@8142", "sap_hostname": "http://10.10.10.10:8001", "sap_print_queues": [{"queue_name": "ZQ1", "print_share_id": "decfbbe1-819f-4231-b72c-f287227313d1"}]}',
        properties=SecretProperties(
            name="BGPRINT",
            vault_id="https://test.vault.azure.net/secrets/BGPRINT/",
            attributes=None,
        ),
    ),
    KeyVaultSecret(
        value='{"sap_sid": "TT1", "sap_environment": "DEV", "sap_user": "DEVANSH", "sap_password": "Spartan@8142", "sap_hostname": "http://10.186.102.6:8001", "sap_print_queues": [{"queue_name": "ZQ1", "print_share_id": "decfbbe1-819f-4231-b72c-f287227313d1"}]}',
        properties=SecretProperties(
            name="BGPRINT2",
            vault_id="https://test.vault.azure.net/secrets/BGPRINT/",
            attributes=None,
        ),
    ),
]
PRINT_QUEUE_ITEM = [
    {
        "QItemId": "000D3A8F76881EEEB9CA438BFCA307BA",
        "Documents": '[{"document_name":"970595_00001","filesize":16911,"blob":"ASDJAHSKDJHASKD"}]',
        "QItemParams": '{"version":"1.1","print_job":{"copies":1 }}',
    },
    {
        "QItemId": "000D3A8F76881EEEB9CA47D829DDC7BA",
        "Documents": '[{"document_name":"970596_00001","filesize":16911,"blob":"KJHGDFSDF&DSF"}]',
        "QItemParams": '{"version":"1.1","print_job":{"copies":1 }}',
    },
]

STORAGE_QUEUE_ITEMS = [
    (
        QueueMessage(content=b'{}'),
        {
            "print_item": {"queue_item_id": "id"},
            "sap_sid": "sid",
            "sap_environment": "DEV",
            "sap_print_queue_name": "queue1",
        },
    ),
    (
        QueueMessage(content=b'{}'),
        {
            "print_item": {"queue_item_id": "id"},
            "sap_sid": "sid",
            "sap_environment": "DEV",
            "sap_print_queue_name": "queue1",
        },
    ),
]

QUEUE_RESPONSE = {
    "d": {
        "results": [
            {"Qname": "queue1"},
            {"Qname": "queue2"},
        ]
    }
}

NUMBER_OF_PRINT_ITEMS = {"d": {"NrOfNewItems": 2}}

PRINT_ITEMS_SAP = {
    "d": {
        "results": [
            {
                "QItemId": "000D3A8F76881EDEBAF3CFAC678AD237",
                "Documents": '[{"document_name":"971676_00001","filesize":16911,"blob":"JVBERi0xLjMNCiXi4"}]',
                "QItemParams": '{"version":"1.1","print_job":{"copies":1 }}',
                "Metadata": '{"version":"1.2","metadata":{"business_metadata":{"business_user":"","object_type":"","object_type_id":"","object_node_type":"","object_node_type_id":""},"communication_metadata":{"communication_user":"PM4ADMIN","communication_id":"","package_id":0,"sending_timestamp":20240326220224.3214950,"system_id":"PM4"},"print_metadata":{"created_by":"DEVANSH","mergeddoc_page_numbers":""}}}',
            },
            {
                "QItemId": "000D3A8F76881EDEBAF3DA2FE355123C",
                "Documents": '[{"document_name":"971677_00001","filesize":16911,"blob":"ASHGSJFGJSD"}]',
                "QItemParams": '{"version":"1.1","print_job":{"copies":1 }}',
                "Metadata": '{"version":"1.2","metadata":{"business_metadata":{"business_user":"","object_type":"","object_type_id":"","object_node_type":"","object_node_type_id":""},"communication_metadata":{"communication_user":"PM4ADMIN","communication_id":"","package_id":0,"sending_timestamp":20240326220224.3214950,"system_id":"PM4"},"print_metadata":{"created_by":"DEVANSH","mergeddoc_page_numbers":""}}}',
            },
        ]
    }
}
