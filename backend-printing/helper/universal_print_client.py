"""Azure Universal Print.
"""

import re
import base64
import requests
import os


class UniversalPrintClient:
    def __init__(self) -> None:
        pass

    def upload_document(self, request_body: dict):
        """Upload the document to the Universal Print.

        Args:
            file_path (str): file path

        Returns:
            dict: response
        """
        try:
            range = [
                int(num)
                for num in re.findall(r"\d+", request_body["next_expected_range"])
            ]
            blob_data = base64.b64decode(request_body["document_blob"])
            content_range = f"bytes 0-{len(blob_data) - 1}/{len(blob_data)}"
            headers = {
                "Content-Type": "application/json",
                "Content-Range": content_range,
                "Content-Length": str(len(blob_data)),
                "Accept": "*/*",
            }
            response = requests.put(
                url=request_body["upload_url"], headers=headers, data=blob_data
            )
            return response
        except Exception as e:
            raise Exception(
                f"Exception occurred while uploading the document to the UP URL: {e}"
            )


class UniversalPrintUsingLogicApp:
    def call_logic_app(print_items) -> requests.Response:
        """Call the logic app to print the items.
        Args:
            print_item: print item json message

        Returns:
            dict: response
        """
        try:
            headers = {"Content-Type": "application/json"}
            response = requests.post(
                url=os.environ["LOGIC_APP_URL"],
                headers=headers,
                json=print_items,
            )
            return response
        except Exception as e:
            raise Exception(f"Error occurred while calling logic app: {e}")
