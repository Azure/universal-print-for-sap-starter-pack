"""time trigger function to fetch print items from the
storge account queue and send them to the universal print
"""

import logging
import azure.functions as func
from helper.backend_print import BackendPrint


def main(mytimer: func.TimerRequest, context: func.Context) -> None:
    """Main function to fetch print items from the storage account queue
    and send them to the universal print.
    Args:
        mytimer (func.TimerRequest): timer trigger
        context (func.Context): context
    """
    logging.info(f"Python timer trigger function started. {context.invocation_id}")
    BackendPrint(
        logger=logging, log_tag="SendPrintJobs"
    ).send_print_items_to_universal_print()
