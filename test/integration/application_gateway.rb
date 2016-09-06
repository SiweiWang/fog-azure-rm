require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

rs = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

application_gateway = Fog::ApplicationGateway::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

network = Fog::Network::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

# rs.resource_groups.create(
#   name: 'TestRG-AG',
#   location: 'eastus'
# )

# network.virtual_networks.create(
#   name: 'testVnet1',
#   location: 'eastus',
#   resource_group: 'TestRG-AG',
#   dns_servers: %w(10.1.0.0 10.2.0.0),
#   address_prefixes: %w(10.1.0.0/16 10.2.0.0/16)
# )
#
# network.subnets.create(
#   name: 'mysubnet1',
#   resource_group: 'TestRG-AG',
#   virtual_network_name: 'testVnet1',
#   address_prefix: '10.1.0.0/24'
# )
#
# network.public_ips.create(
#   name: 'mypubip1',
#   resource_group: 'TestRG-AG',
#   location: 'eastus',
#   public_ip_allocation_method: 'Dynamic'
# )

########################################################################################################################
######################                          Create Application Gateway                        ######################
########################################################################################################################




application_gateway = application_gateway.gateways.get('gateway', 'TestRG-AG')
application_gateway.destroy


# application_gateway.gateways.create(
#   name: 'gateway',
#   location: 'eastus',
#   resource_group: 'TestRG-AG',
#   sku_name: 'Standard_Medium',
#   sku_tier: 'Standard',
#   sku_capacity: '2',
#   gateway_ip_configurations: [{
#     name: 'gatewayIpConfigName',
#     subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourcegroups/TestRG-AG/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet"
#   }],
#   frontend_ip_configurations: [{
#     name: 'frontendIpConfig',
#     private_ip_allocation_method: 'Dynamic',
#     public_ip_address_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourcegroups/TestRG-AG/providers/Microsoft.Network/publicIPAddresses/mypubip",
#     private_ip_address: '10.0.1.5'
#   }],
#   frontend_ports: [{
#     name: 'frontendPort',
#     port: 443
#   }],
#   backend_address_pools: [{
#     name: 'backendAddressPool',
#     ip_addresses: [{
#       ipAddress: '10.0.1.6'
#     }]
#   }],
#   backend_http_settings_list: [{
#     name: 'gateway_settings',
#     port: 80,
#     protocol: 'Http',
#     cookie_based_affinity: 'Enabled',
#     request_timeout: '30'
#   }],
#   http_listeners: [{
#     name: 'gateway_listener',
#     frontend_ip_config_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-AG/providers/Microsoft.Network/applicationGateways/gateway/frontendIPConfigurations/frontendIpConfig",
#     frontend_port_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-AG/providers/Microsoft.Network/applicationGateways/gateway/frontendPorts/frontendPort",
#     protocol: 'Http',
#     host_name: '',
#     require_server_name_indication: 'false'
#   }],
#   request_routing_rules: [{
#     name: 'gateway_request_route_rule',
#     type: 'Basic',
#     http_listener_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-AG/providers/Microsoft.Network/applicationGateways/gateway/httpListeners/gateway_listener",
#     backend_address_pool_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-AG/providers/Microsoft.Network/applicationGateways/gateway/backendAddressPools/backendAddressPool",
#     backend_http_settings_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-AG/providers/Microsoft.Network/applicationGateways/gateway/backendHttpSettingsCollection/gateway_settings",
#     url_path_map: ''
#   }]
# )

########################################################################################################################
######################                      Get and Destroy Application Gateway                   ######################
########################################################################################################################

pubip = network.public_ips.get('TestRG-AG', 'mypubip')
pubip.destroy

vnet = network.virtual_networks.get('TestRG-AG', 'testVnet')
vnet.destroy

resource_group = rs.resource_groups.get('TestRG-AG')
resource_group.destroy

ag = application_gateway.gateways(resource_group: 'TestRG-AG').get('gateway')
ag.add_gateway_ip_configuration({
    name: 'gatewayIpConfigName1',
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourcegroups/TestRG-AG/providers/Microsoft.Network/virtualNetworks/testVnet1/subnets/mysubnet1"
  })
# ag.destroy
#
# ########################################################################################################################
# ######################                                   CleanUp                                  ######################
# ########################################################################################################################
#
# pubip = network.public_ips.get('TestRG-AG', 'mypubip')
# pubip.destroy
#
# vnet = network.virtual_networks.get('TestRG-AG', 'testVnet')
# vnet.destroy
#
# rg = rs.resource_groups.get('TestRG-AG')
# rg.destroy
