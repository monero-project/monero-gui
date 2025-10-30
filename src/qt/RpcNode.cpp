#include "RpcNode.h"
#include "utils.h"

RpcNode::RpcNode(const QString &uri, bool online) {
    this->online = online;
    this->picked = false;

    if (!uri.contains(":")) {
        host = uri;
        port = 80;
    } else {
        QUrl url = QUrl("http://" + uri);
        host = url.host();
        port = url.port();
    }
}

RpcNode::RpcNode(const QString &host, int port, bool online) {
    this->host = host;
    this->port = port;
    this->online = online;
    this->picked = false;
}

bool RpcNode::isOnion() const {
    return host.contains(".onion");
}

bool RpcNode::isI2P() const {
    return host.contains(".b32.i2p");
}

QString RpcNode::getServer() const {
    if (host.isEmpty()) return QString("");
    if (port && port != 80) return "http://" + host + ":" + QString::fromStdString(std::to_string(port));
    return "http://" + host;
}

void RpcNode::checkConnection(const std::shared_ptr<epee::net_utils::http::abstract_http_client> &httpClient) {
    online = false;
    std::string response = "";
    QString url = getServer();
    
    if (!httpClient->set_server(url.toStdString(), {})) {
        qWarning() << "Invalid rpc node found: " << url;
        return;
    }

    const QUrl urlParsed(url);

    const QString path = "/get_info";
    qWarning() << "Checking bootstrap node " << url << "...";
    const epee::net_utils::http::http_response_info *pri = NULL;
    constexpr std::chrono::milliseconds timeout = std::chrono::seconds(5);
    QString contentType = "application/json; charset=utf-8";
    epee::net_utils::http::fields_list headers({{"User-Agent", randomUserAgent().toStdString()}});
    headers.push_back({"Content-Type", contentType.toStdString()});

    const bool result = httpClient->invoke(path.toStdString(), "GET", {}, timeout, std::addressof(pri), headers);
    if (!result)
    {
        qWarning() << "Cannot check bootstrap node: unknown error";
        return;
    }
    if (!pri)
    {
        qWarning() << "Cannot check bootstrap node: internal error";
        return;
    }
    if (pri->m_response_code != 200)
    {
        qWarning() << QString("Cannot check bootstrap node: response code %1").arg(pri->m_response_code);
        return;
    }

    response = std::move(pri->m_body);
    qDebug() << "Got response: " << QString::fromStdString(response);
    // TODO better RPC response validation
    online = !response.empty();
}

void RpcNodes::add(const std::shared_ptr<RpcNode> &node) {
    m_nodes.push_back(node);
}

void RpcNodes::add(const QString &uri, bool online) {
    auto node = std::make_shared<RpcNode>(uri, online);
    add(node);
}

void RpcNodes::add(const QString &host, int port, bool online) {
    auto node = std::make_shared<RpcNode>(host, port, online);
    add(node);
}

void RpcNodes::remove(const std::shared_ptr<RpcNode> &node) {
    std::remove_if(m_nodes.begin(), m_nodes.end(), [&node](const std::shared_ptr<RpcNode> &n) {
        return node == n;
    });
}

void RpcNodes::clear() {
    m_nodes.clear();
}

void RpcNodes::unpick() {
    for (const auto &node : m_nodes) {
        node->picked = false;
    }
}

void RpcNodes::checkConnection(const std::shared_ptr<epee::net_utils::http::abstract_http_client> &httpClient) {
    for(const auto &node : m_nodes) {
        node->checkConnection(httpClient);
    }
}

std::vector<std::shared_ptr<RpcNode>> RpcNodes::getNodes(RpcNodeType type, bool onlyOnline) const {
    std::vector<std::shared_ptr<RpcNode>> nodes;
    bool tor = type == RpcNodeType::TOR;
    bool i2p = type == RpcNodeType::I2P;

    for (const auto &node : m_nodes) {
        if ((onlyOnline && !node->online) || (tor && !node->isOnion()) || (i2p && !node->isI2P())) continue;
        nodes.push_back(node);
    }

    return nodes;
}

std::shared_ptr<RpcNodes> RpcNodes::filter(RpcNodeType type) const {
    auto nodes = getNodes(type, false);
    return std::make_shared<RpcNodes>(nodes);
}

bool RpcNodes::allPicked() const {
    for (const auto &node : m_nodes) {
        if (!node->picked) return false;
    }

    return true;
}

bool RpcNodes::allOffline() const {
    for (const auto &node : m_nodes) {
        if (node->online) return false;
    }

    return true;
}

BootstrapNodes::BootstrapNodes() {
    m_httpClient = std::make_shared<net::http::client>();
    m_mainnetRpcNodes = std::make_shared<RpcNodes>();
    m_testnetRpcNodes = std::make_shared<RpcNodes>();
    m_stagenetRpcNodes = std::make_shared<RpcNodes>();
    load();
}

void BootstrapNodes::load() {
    QByteArray file = fileOpenQRC(":/js/nodes.json");
    QJsonDocument nodesJson = QJsonDocument::fromJson(file);
    QJsonObject nodesObj = nodesJson.object();

    m_mainnetRpcNodes->clear();
    m_testnetRpcNodes->clear();
    m_stagenetRpcNodes->clear();

    if (nodesObj.contains("mainnet")) {
        auto clearnet_nodes_list = nodesJson["mainnet"].toObject()["clearnet"].toArray();
        auto tor_nodes_list = nodesJson["mainnet"].toObject()["tor"].toArray();
        auto i2p_nodes_list = nodesJson["mainnet"].toObject()["i2p"].toArray();
        
        for (const auto &node : clearnet_nodes_list) {
            m_mainnetRpcNodes->add(node.toString());
        }

        for (const auto &node : tor_nodes_list) {
            m_mainnetRpcNodes->add(node.toString());
        }

        for (const auto &node : i2p_nodes_list) {
            m_mainnetRpcNodes->add(node.toString());
        }
    }

    if (nodesObj.contains("testnet")) {
        auto clearnet_nodes_list = nodesJson["testnet"].toObject()["clearnet"].toArray();
        auto tor_nodes_list = nodesJson["testnet"].toObject()["tor"].toArray();
        auto i2p_nodes_list = nodesJson["testnet"].toObject()["i2p"].toArray();
        
        for (const auto &node : clearnet_nodes_list) {
            m_testnetRpcNodes->add(node.toString());
        }

        for (const auto &node : tor_nodes_list) {
            m_testnetRpcNodes->add(node.toString());
        }

        for (const auto &node : i2p_nodes_list) {
            m_testnetRpcNodes->add(node.toString());
        }
    }

    if (nodesObj.contains("stagenet")) {
        auto clearnet_nodes_list = nodesJson["stagenet"].toObject()["clearnet"].toArray();
        auto tor_nodes_list = nodesJson["stagenet"].toObject()["tor"].toArray();
        auto i2p_nodes_list = nodesJson["stagenet"].toObject()["i2p"].toArray();
        
        for (const auto &node : clearnet_nodes_list) {
            m_stagenetRpcNodes->add(node.toString());
        }

        for (const auto &node : tor_nodes_list) {
            m_stagenetRpcNodes->add(node.toString());
        }

        for (const auto &node : i2p_nodes_list) {
            m_stagenetRpcNodes->add(node.toString());
        }
    }
}

void BootstrapNodes::checkNodesConnection(NetworkType::Type networkType, RpcNodeType type, const QString &proxyAddress) {
    bool tor = type == RpcNodeType::TOR;
    bool i2p = type == RpcNodeType::I2P;
    bool clearnet = !tor && !i2p;

    if (clearnet && !proxyAddress.isEmpty()) m_httpClient->set_proxy(proxyAddress.toStdString());
    else if (tor) m_httpClient->set_proxy(TOR_PROXY_ADDRESS);
    else if (i2p) m_httpClient->set_proxy(I2P_PROXY_ADDRESS);

    auto rpcNodes = getRpcNodes(networkType, type);

    rpcNodes->checkConnection(m_httpClient);
}

std::shared_ptr<RpcNodes> BootstrapNodes::getRpcNodes(NetworkType::Type networkType, RpcNodeType type) const {
    if (networkType == NetworkType::Type::MAINNET) return m_mainnetRpcNodes->filter(type);
    else if (networkType == NetworkType::Type::STAGENET) return m_stagenetRpcNodes->filter(type);
    else return m_testnetRpcNodes->filter(type);
}

std::shared_ptr<RpcNode> BootstrapNodes::pickRandom(NetworkType::Type networkType, RpcNodeType type) {
    bool tor = type == RpcNodeType::TOR;
    bool i2p = type == RpcNodeType::I2P;

    for(;;) {
        auto node = getRandom(networkType, type);
        
        if (node->online) return node;
        if (node->picked) continue;

        if (tor) m_httpClient->set_proxy(TOR_PROXY_ADDRESS);
        else if (i2p) m_httpClient->set_proxy(I2P_PROXY_ADDRESS);

        node->checkConnection(m_httpClient);
        node->picked = true;

        if (node->online) {
            return node;
        }

        if (allPicked(networkType, type) && allOffline(networkType, type)) {
            unpick(networkType, type);
            throw std::runtime_error("No rpc nodes found");
        }
    }
}

std::shared_ptr<RpcNode> BootstrapNodes::getRandom(NetworkType::Type networkType, RpcNodeType type) const {
    std::shared_ptr<RpcNodes> rpcNodes = getRpcNodes(networkType, type);

    auto nodes = rpcNodes->getNodes(type, false);

    if (nodes.empty()) throw std::runtime_error("No rpc nodes found");

    QVector<int> node_indices;
    int i = 0;
    for (const auto &node: nodes) {
        node_indices.push_back(i);
        i++;
    }

    unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
    std::shuffle(node_indices.begin(), node_indices.end(), std::default_random_engine(seed));
    int randomIndex = node_indices[0];

    return nodes[randomIndex];
}

bool BootstrapNodes::allPicked(NetworkType::Type networkType, RpcNodeType type) const {
    auto nodes = getRpcNodes(networkType, type);
    return nodes->allPicked();
}

bool BootstrapNodes::allOffline(NetworkType::Type networkType, RpcNodeType type) const {
    auto nodes = getRpcNodes(networkType, type);
    return nodes->allOffline();
}

void BootstrapNodes::unpick(NetworkType::Type networkType, RpcNodeType type) {
    auto nodes = getRpcNodes(networkType, type);
    nodes->unpick();
}
