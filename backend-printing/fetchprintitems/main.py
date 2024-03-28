"""time trigger function to fetch print items from the SAP system and put them in the storage account queue
"""

import logging
import azure.functions as func
from helper.backend_print import BackendPrint


def main(mytimer: func.TimerRequest, context: func.Context) -> None:
    logging.info(f"Python timer trigger function started. {context.invocation_id}")
    BackendPrint(logger=logging, log_tag="FetchPrintItems").fetch_print_items_from_sap()
