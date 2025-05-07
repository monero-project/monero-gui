# Add I2P related methods to the Wallet class
# Add after isOffline method but before getFilename method

bool WalletImpl::isI2PEnabled() const
{
    return m_wallet->i2p_enabled();
}

void WalletImpl::setI2PEnabled(bool enabled)
{
    m_wallet->set_i2p_enabled(enabled);
}

void WalletImpl::setI2POptions(const std::string &options)
{
    m_wallet->set_i2p_options(options);
}

std::string WalletImpl::getI2POptions() const
{
    return m_wallet->get_i2p_options();
} 