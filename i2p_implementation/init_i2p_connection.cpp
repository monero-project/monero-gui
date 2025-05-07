bool wallet2::init_i2p_connection()
{
  if (!m_i2p_enabled || m_i2p_options.empty())
    return true;
    
  std::string i2p_address;
  int i2p_port;
  
  if (!parse_i2p_options(m_i2p_options, i2p_address, i2p_port))
  {
    LOG_ERROR("Failed to parse I2P options");
    return false;
  }
  
  // Format the proxy address for the HTTP client
  std::string proxy_address = "socks5://" + i2p_address + ":" + std::to_string(i2p_port);
  
  // Set the proxy in the HTTP client
  if (!m_http_client->set_proxy(proxy_address))
  {
    LOG_ERROR("Failed to set I2P proxy: " << proxy_address);
    return false;
  }
  
  LOG_PRINT_L1("I2P proxy set to: " << proxy_address);
  
  // Invalidate the RPC proxy to force reconnection through I2P
  m_node_rpc_proxy.invalidate();
  
  return true;
} 