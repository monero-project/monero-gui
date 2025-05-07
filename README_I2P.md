# Using I2P with Monero GUI

This guide explains how to use the I2P network integration in the Monero GUI wallet to enhance your privacy.

## What is I2P?

The Invisible Internet Project (I2P) is a network layer that allows for censorship-resistant, peer-to-peer communication. By routing Monero traffic through I2P, you can add an extra layer of privacy to your transactions and communications with the Monero network.

## Benefits of Using I2P with Monero

- **Enhanced Privacy**: Hide your IP address from the Monero network
- **Censorship Resistance**: Bypass network restrictions that might block Monero traffic
- **Network-level Protection**: Add another layer of privacy on top of Monero's built-in privacy features

## Getting Started

### Enabling I2P in Monero GUI

1. Open your Monero GUI wallet
2. Go to **Settings** > **Node**
3. Click on the **I2P Network** section
4. In the dialog that appears, configure your I2P settings:
   - Choose whether to use the built-in I2P daemon or an external I2P router
   - Configure advanced options if needed
5. Click **Save** to apply the settings

### Understanding the I2P Status Indicator

The I2P status indicator is located in the left panel of the wallet:
- **Green**: I2P is connected and working properly
- **Red**: I2P is enabled but not connected

You can click on the indicator to:
- Check the current status
- Access I2P settings
- Restart the I2P daemon (if using built-in I2P)

## Configuration Options

### Basic Options

- **Use built-in I2P**: When enabled, Monero GUI will manage its own I2P router
- **Use external I2P**: Connect to an existing I2P router running on your system

### Advanced Options

- **I2P address**: The address of your external I2P router (default: 127.0.0.1)
- **I2P port**: The SAM port of your external I2P router (default: 7656)
- **Allow mixed mode**: Allow connections to both I2P and clearnet peers
- **Inbound tunnels**: Number of inbound tunnels (1-16)
- **Outbound tunnels**: Number of outbound tunnels (1-16)

## Tips for Using I2P Effectively

1. **Be patient**: I2P connections can take longer to establish and may be slower than clearnet connections
2. **Understand the trade-offs**: Using I2P adds privacy but may reduce performance
3. **Consider your threat model**: If you need maximum privacy, disable mixed mode
4. **Check your connections**: Verify that the I2P status indicator shows a successful connection

## Troubleshooting

### Common Issues

1. **I2P daemon won't start**
   - Check if another I2P router is already running
   - Verify that ports 7656 and 7070 are not in use
   - Restart the Monero GUI wallet

2. **Slow synchronization**
   - This is normal when using I2P
   - Try increasing the number of tunnels
   - Be patient during initial synchronization

3. **Cannot connect to I2P network**
   - Ensure your internet connection is working
   - Try restarting the I2P daemon
   - Check the logs for specific error messages

## Frequently Asked Questions

**Q: Will using I2P make my transactions more private?**  
A: I2P adds privacy at the network level by hiding your IP address, complementing Monero's built-in privacy features.

**Q: Does using I2P slow down my wallet?**  
A: Yes, using I2P may result in slower connections due to the additional routing through the I2P network.

**Q: Can I use I2P with a remote node?**  
A: Yes, I2P can be used with both local and remote nodes.

**Q: Is the built-in I2P daemon as secure as using a separate I2P router?**  
A: The built-in daemon provides good security for most users. Advanced users might prefer running a separate, dedicated I2P router.

**Q: What is "mixed mode" and should I use it?**  
A: Mixed mode allows connections to both I2P and clearnet peers. It improves reliability but may reduce privacy. Use it based on your privacy needs.

## Getting Help

If you encounter issues with the I2P integration:

1. Check the [Monero GUI documentation](https://github.com/monero-project/monero-gui/blob/master/docs/I2P_INTEGRATION.md)
2. Ask for help on the [Monero community channels](https://www.getmonero.org/community/hangouts/)
3. Report bugs on the [Monero GUI GitHub repository](https://github.com/monero-project/monero-gui/issues) 