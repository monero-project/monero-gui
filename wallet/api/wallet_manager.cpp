# Add I2P related methods to the WalletManager class implementation
# Add before the closeWallet method implementation

bool WalletManagerImpl::isI2PEnabled(const Wallet &wallet) const
{
    return wallet.isI2PEnabled();
}

void WalletManagerImpl::setI2PEnabled(Wallet &wallet, bool enabled)
{
    wallet.setI2PEnabled(enabled);
}

void WalletManagerImpl::setI2POptions(Wallet &wallet, const std::string &options)
{
    wallet.setI2POptions(options);
}

std::string WalletManagerImpl::getI2POptions(const Wallet &wallet) const
{
    return wallet.getI2POptions();
} 