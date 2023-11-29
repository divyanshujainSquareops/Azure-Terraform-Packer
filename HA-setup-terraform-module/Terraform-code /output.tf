output "application_gateway_public_ip" {
    value = data.azurerm_public_ip.Application-Gateway-publicip.ip_address
    description = "application-gateway-public-ip"  
}
output "name_servers" {
  value = azurerm_dns_zone.dns_zone.name_servers
}
output "a_record_url" {
  value = azurerm_dns_a_record.a_record.fqdn
}
