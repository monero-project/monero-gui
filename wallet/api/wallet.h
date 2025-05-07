# Add I2P related method declarations to the Wallet class
# Add after virtual bool isOffline() const = 0; declaration but before virtual std::string getFilename() const = 0;

    virtual bool isI2PEnabled() const = 0;
    virtual void setI2PEnabled(bool enabled) = 0;
    virtual void setI2POptions(const std::string &options) = 0;
    virtual std::string getI2POptions() const = 0; 