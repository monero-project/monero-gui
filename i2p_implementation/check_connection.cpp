if (version)
  *version = m_rpc_version;

// If I2P is enabled, discover I2P peers
if (m_i2p_enabled)
{
  discover_i2p_peers();
}

return true;
} 