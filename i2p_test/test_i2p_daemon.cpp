#include "../src/i2p/i2pdaemonmanager.h"
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "Testing I2PDaemonManager..." << std::endl;
    
    I2PDaemonManager& manager = I2PDaemonManager::instance();
    
    std::cout << "Config directory: " << manager.getConfigDir() << std::endl;
    std::cout << "Data directory: " << manager.getDataDir() << std::endl;
    
    // Check initial state
    std::cout << "Initial state - Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    // Test setting tunnel length
    std::cout << "Setting tunnel length to 4..." << std::endl;
    bool setTunnelResult = manager.setTunnelLength(4);
    std::cout << "Set tunnel length result: " << (setTunnelResult ? "Success" : "Failed") << std::endl;
    std::cout << "Current tunnel length: " << manager.getTunnelLength() << std::endl;
    
    // Start daemon
    std::cout << "Starting I2P daemon..." << std::endl;
    bool startResult = manager.start();
    std::cout << "Start result: " << (startResult ? "Success" : "Failed") << std::endl;
    std::cout << "Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    // Wait a bit
    std::cout << "Waiting for 2 seconds..." << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(2));
    
    // Stop daemon
    std::cout << "Stopping I2P daemon..." << std::endl;
    bool stopResult = manager.stop();
    std::cout << "Stop result: " << (stopResult ? "Success" : "Failed") << std::endl;
    std::cout << "Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    std::cout << "Test completed." << std::endl;
    return 0;
}
