"""Contains the key vault for the application.
This is where all the SAP config are set and get.
"""

from dataclasses import asdict
from helper.azure_client import AzureClient


class KeyVault(AzureClient):

    def get_sap_config(self, secret_name):
        """Gets the SAP config from the key vault.

        Args:
            secret_name (string): Name of the secret
        Returns:
            dict: SAP config
        """
        try:
            return self.key_vault_client.get_secret(secret_name)
        except Exception as e:
            raise Exception(
                f"Error occurred getting SAP config with name {secret_name}: {e}"
            )

    def get_sap_config_secrets(self):
        """Gets the SAP config secrets from the key vault.

        Returns:
            list[json]: SAP config secrets
        """
        try:
            sap_secrets = []
            secret_properties = self.key_vault_client.list_properties_of_secrets()
            for secret in secret_properties:
                if secret.name.startswith("BGPRINT"):
                    try:
                        sap_secrets.append(self.get_sap_config(secret.name))
                    except Exception as e:
                        print(e)
            return sap_secrets
        except Exception as e:
            raise Exception(f"Error occurred getting SAP config: {e}")

    def set_kv_secrets(self, secret_key, secret_value):
        """Set the secret key and value to the key vault.

        Args:
            secret_key (string): Key name
            secret_value (string): value of the key

        Raises:
            Exception: Error occurred setting the secret

        Returns:
            boolean: True if the secret is successfully set
        """
        try:
            self.key_vault_client.set_secret(secret_key, secret_value)
            return True
        except Exception as e:
            raise Exception(f"Error occurred setting SAP config: {e}")
