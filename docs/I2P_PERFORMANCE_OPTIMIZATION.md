# I2P Performance Optimization Guide

This document provides guidance on optimizing the performance of the I2P integration in Monero GUI.

## Understanding I2P Performance Characteristics

I2P, by design, prioritizes anonymity over speed. This means that I2P connections will generally be slower than clearnet connections due to:

1. Multi-hop routing through several nodes
2. Encryption/decryption at each hop
3. Tunnel creation and management overhead
4. Bandwidth limitations of the I2P network

However, there are several ways to optimize I2P performance while maintaining privacy.

## Tunnel Configuration Optimization

### Quantity vs. Privacy Trade-offs

- **Inbound Tunnels**: Controls how many tunnels are available for receiving data
  - Higher values increase reliability but consume more resources
  - Recommended range: 3-5 for normal use, 2 for low-resource systems

- **Outbound Tunnels**: Controls how many tunnels are available for sending data
  - Higher values increase throughput but consume more resources
  - Recommended range: 3-5 for normal use, 2 for low-resource systems

### Length vs. Speed Trade-offs

- **Tunnel Length**: Controls how many hops are in each tunnel
  - Longer tunnels provide more anonymity but increase latency
  - Shorter tunnels are faster but potentially less anonymous
  - Default length (3) is a good balance for most users

## Resource Usage Optimization

### Memory Usage

The I2P daemon (i2pd) can consume significant memory, especially on resource-constrained systems. To optimize:

1. Limit the number of tunnels (as described above)
2. Consider using the "low bandwidth" option if available
3. Close other memory-intensive applications when using I2P
4. Monitor memory usage and adjust settings accordingly

### CPU Usage

I2P encryption and routing can be CPU-intensive. To optimize:

1. Ensure your system meets the minimum requirements
2. Use a reasonable number of tunnels based on your CPU capabilities
3. Consider reducing the tunnel length if CPU usage is consistently high
4. Monitor CPU usage and adjust settings accordingly

### Disk I/O

I2P maintains a network database that requires disk access. To optimize:

1. Place the I2P data directory on an SSD if possible
2. Ensure sufficient free space (at least 1GB recommended)
3. Consider periodic cleanup of old data if long-term usage causes growth

## Network Optimization

### Bandwidth Management

I2P can consume significant bandwidth. To optimize:

1. Set appropriate bandwidth limits in the I2P configuration
2. Consider using the "share bandwidth" option conservatively
3. Monitor bandwidth usage and adjust settings accordingly

### Connection Stability

For more stable connections:

1. Use a reliable internet connection
2. Consider increasing the number of tunnels slightly if connections are unstable
3. Allow sufficient time for tunnel establishment before transactions
4. Enable mixed mode for critical operations if pure I2P is unstable

## Application-level Optimization

### Wallet Synchronization

Wallet synchronization through I2P can be slow. To optimize:

1. Use a local node when possible
2. Consider performing initial synchronization over clearnet, then switching to I2P
3. Use bootstrap nodes that are known to be reliable over I2P
4. Set reasonable expectations for synchronization time

### Transaction Broadcasting

To optimize transaction broadcasting:

1. Ensure sufficient outbound tunnels (3-5 recommended)
2. Be patient - transactions may take longer to propagate through I2P
3. Consider using mixed mode for time-sensitive transactions
4. Monitor transaction status and be prepared to rebroadcast if necessary

## Implementation-specific Optimizations

### I2P Daemon Management

1. Start the I2P daemon early in the application lifecycle
2. Allow sufficient time for the I2P network to bootstrap before use
3. Implement graceful shutdown to preserve network state
4. Consider persistent I2P identities for faster reconnection

### Peer Discovery

1. Maintain a list of known good I2P peers
2. Implement smart peer selection based on performance metrics
3. Regularly update the peer list with working nodes
4. Share peer information between sessions

## Monitoring and Tuning

### Performance Metrics to Monitor

1. Connection establishment time
2. Transaction propagation time
3. Memory and CPU usage of the I2P daemon
4. Bandwidth consumption
5. Success rate of I2P operations

### Tuning Process

1. Establish baseline performance
2. Make one change at a time
3. Measure the impact of each change
4. Document optimal settings for different environments

## Platform-specific Considerations

### Windows

- Ensure Windows Defender or other security software is not blocking I2P
- Consider running with elevated privileges if necessary
- Monitor resource usage in Task Manager

### macOS

- Check System Integrity Protection settings if issues occur
- Monitor resource usage in Activity Monitor
- Ensure proper permissions for the I2P data directory

### Linux

- Consider using nice/ionice to adjust process priority
- Monitor resource usage with top/htop
- Check system logs for any I2P-related issues

## Conclusion

Optimizing I2P performance is a balance between privacy, reliability, and speed. The recommendations in this guide should help achieve reasonable performance while maintaining the privacy benefits of I2P. Always remember that I2P will be inherently slower than clearnet connections, but with proper optimization, the difference can be minimized to provide a good user experience. 