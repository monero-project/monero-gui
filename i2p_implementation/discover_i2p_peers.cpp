bool wallet2::discover_i2p_peers()
{
  // Skip if I2P is not enabled
  if (!m_i2p_enabled)
    return false;

  MINFO("Discovering I2P peers...");
  
  // If we don't have a connection or proxy set, initialize I2P connection
  if (!m_http_client.get() || !m_http_client->is_connected())
  {
    if (!init_i2p_connection())
    {
      MERROR("Failed to initialize I2P connection for peer discovery");
      return false;
    }
  }
  
  // Fetch list of I2P peers from seed nodes
  std::vector<std::string> seed_nodes = get_seed_nodes(true); // true for I2P mode
  std::vector<std::string> peer_list;
  
  for (const auto& seed : seed_nodes)
  {
    try
    {
      // Request peer list from seed node
      epee::json_rpc::request<cryptonote::COMMAND_RPC_GET_PEER_LIST::request> req;
      epee::json_rpc::response<cryptonote::COMMAND_RPC_GET_PEER_LIST::response, std::string> res;
      
      req.jsonrpc = "2.0";
      req.id = epee::serialization::storage_entry(0);
      req.method = "get_peer_list";
      
      bool success = epee::net_utils::invoke_http_json("/json_rpc", req, res, *m_http_client);
      
      if (success && res.result.peers.size() > 0)
      {
        // Store only I2P peers
        for (const auto& peer : res.result.peers)
        {
          if (peer.adr.substr(0, 4) == "i2p.")
            peer_list.push_back(peer.adr);
        }
      }
    }
    catch (const std::exception& e)
    {
      MWARNING("Error retrieving I2P peers from seed " << seed << ": " << e.what());
    }
  }
  
  MINFO("Discovered " << peer_list.size() << " I2P peers");
  return peer_list.size() > 0;
} 