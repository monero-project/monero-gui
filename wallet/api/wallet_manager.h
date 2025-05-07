# Add I2P related method declarations to the WalletManager class
# Add after the virtual net::URI parseUri / resolveOpenAlias method declarations but before the closeWallet method

    virtual bool isI2PEnabled(const Wallet &wallet) const = 0;
    virtual void setI2PEnabled(Wallet &wallet, bool enabled) = 0;
    virtual void setI2POptions(Wallet &wallet, const std::string &options) = 0;
    virtual std::string getI2POptions(const Wallet &wallet) const = 0; 