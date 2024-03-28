#########################################################################################
#                                                                                       #
#  Environment definitions                                                              #
#                                                                                       #
#########################################################################################

# The subscription_id value is a mandatory field, it is used to control where the resources are deployed
subscription_id = ""

# The environment value is a mandatory field, it is used for partitioning the environments, for example (PROD and NON-PROD)
environment = ""

# The location value is a mandatory field, it is used to control where the resources are deployed
location = ""

control_plane_rg = ""

# The virtaul_network_id value is a mandatory field, it is used to control where the resources are deployed
virtual_network_id = ""

# The subnet address prefix value is a mandatory field, it is used to control where the resources are deployed
subnet_address_prefixes = ""

resource_group_tags = {
    "CreatedBy": "SAPonAzureBgPrint",
}
