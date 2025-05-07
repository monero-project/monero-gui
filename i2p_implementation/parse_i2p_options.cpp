bool wallet2::parse_i2p_options(const std::string &options, std::string &address, int &port)
{
  // Parse the I2P options string
  // Expected format: --tx-proxy i2p,<address>,<port> [--allow-mismatched-daemon-version]
  
  // Default values
  address = "127.0.0.1";
  port = 7656;
  
  if (options.empty())
    return true;
    
  std::vector<std::string> args;
  boost::split(args, options, boost::is_any_of(" "));
  
  for (size_t i = 0; i < args.size(); ++i)
  {
    if (args[i] == "--tx-proxy" && i + 1 < args.size())
    {
      std::vector<std::string> proxy_parts;
      boost::split(proxy_parts, args[i+1], boost::is_any_of(","));
      
      if (proxy_parts.size() >= 3 && proxy_parts[0] == "i2p")
      {
        address = proxy_parts[1];
        try {
          port = std::stoi(proxy_parts[2]);
        }
        catch (const std::exception &e) {
          LOG_ERROR("Failed to parse I2P port: " << e.what());
          return false;
        }
        return true;
      }
    }
  }
  
  LOG_ERROR("Failed to parse I2P options: " << options);
  return false;
} 