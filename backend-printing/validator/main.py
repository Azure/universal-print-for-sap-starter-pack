"""
Azure Function to validate connection to SAP system and store the connection details in the Key Vault.
"""

import json
import azure.functions as func
from helper.backend_print import BackendPrint
import logging


def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    """
    Azure Functions entry point to validate connection.

    Args:
        req (func.TimerRequest)
        context (func.Context)
    """
    logging.info("Python HTTP trigger function processed a request.")
    response = BackendPrint(
        logger=logging, log_tag="Validator"
    ).validation_engine(req.get_json())

    return func.HttpResponse(json.dumps(response), status_code=200)
