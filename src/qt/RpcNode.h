
#include <QtCore>
#include "NetworkType.h"
// TODO: wallet_merged - epee library triggers the warnings
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wreorder"
#include <net/http.h>
#pragma GCC diagnostic pop

#define TOR_PROXY_ADDRESS "127.0.0.1:20561"
#define I2P_PROXY_ADDRESS "127.0.0.1:4447"

enum RpcNodeType {
    CLEARNET = 0,
    TOR,
    I2P
};

class RpcNode 
{
public:
    RpcNode(const QString &uri, bool online = false);
    RpcNode(const QString &host, int port, bool online = false);

    QString host;
    int port;
    bool online;
    bool picked;

    bool isOnion() const;
    bool isI2P() const;
    bool isAnonNetwork() const { return isOnion() || isI2P(); };
    QString getServer() const;

    void checkConnection(const std::shared_ptr<epee::net_utils::http::abstract_http_client> &httpClient);
};

class RpcNodes {
public:
    RpcNodes() {};
    RpcNodes(const std::vector<std::shared_ptr<RpcNode>> &nodes) { m_nodes = nodes; };
    std::vector<std::shared_ptr<RpcNode>> getNodes(RpcNodeType type, bool onlyOnline = false) const;
    bool isEmpty() const { return m_nodes.empty(); };
    void add(const std::shared_ptr<RpcNode> &node);
    void add(const QString &uri, bool online = false);
    void add(const QString &host, int port, bool online = false);
    void remove(const std::shared_ptr<RpcNode> &node);
    void clear();
    void checkConnection(const std::shared_ptr<epee::net_utils::http::abstract_http_client> &httpClient);
    bool allPicked() const;
    bool allOffline() const;
    void unpick();
    std::shared_ptr<RpcNodes> filter(RpcNodeType type) const;

private:
    std::vector<std::shared_ptr<RpcNode>> m_nodes;
};


class BootstrapNodes {

public:
    BootstrapNodes();

    void checkNodesConnection(NetworkType::Type networkType, RpcNodeType type, const QString &proxyAddress = "");
    std::shared_ptr<RpcNode> pickRandom(NetworkType::Type networkType, RpcNodeType type);
    std::shared_ptr<RpcNodes> getRpcNodes(NetworkType::Type networkType, RpcNodeType type) const;

private:
    std::shared_ptr<epee::net_utils::http::abstract_http_client> m_httpClient;
    std::shared_ptr<RpcNodes> m_mainnetRpcNodes;
    std::shared_ptr<RpcNodes> m_testnetRpcNodes;
    std::shared_ptr<RpcNodes> m_stagenetRpcNodes;

    void load();
    std::shared_ptr<RpcNode> getRandom(NetworkType::Type networkType, RpcNodeType type) const;
    bool allPicked(NetworkType::Type networkType, RpcNodeType type) const;
    bool allOffline(NetworkType::Type networkType, RpcNodeType type) const;
    void unpick(NetworkType::Type networkType, RpcNodeType type);
};
