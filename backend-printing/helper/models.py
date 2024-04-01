"""Utility functions for the project.
"""

from enum import Enum
from dataclasses import dataclass, field
from marshmallow_dataclass import class_schema


@dataclass
class PrintQueue:
    """A print queue in the SAP system"""

    queue_name: str
    print_share_id: str

@dataclass
class SAPSystem:
    """A SAP system configuration"""

    sap_sid: str = field(default=None, metadata={"required": True})
    sap_environment: str = field(default=None, metadata={"required": True})
    sap_user: str = field(default=None, metadata={"required": True})
    sap_password: str = field(default=None, metadata={"required": True})
    sap_hostname: str = field(default=None, metadata={"required": True})
    sap_print_queues: list[PrintQueue] = field(
        default=list, metadata={"required": False}
    )


class PrintItemStatus(Enum):
    """Enum for the print item status"""

    NEW = "New"
    WAITING = "Waiting"
    IN_PROGRESS = "In Progress"
    COMPLETED = "Completed"
    ERROR = "Error"
