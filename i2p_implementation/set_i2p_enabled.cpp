bool wallet2::set_i2p_enabled(bool enabled)
{
  bool old_value = m_i2p_enabled;
  m_i2p_enabled = enabled;
  
  if (old_value != enabled && enabled)
  {
    // If we're enabling I2P, try to initialize the connection
    return init_i2p_connection();
  }
  
  return true;
} 