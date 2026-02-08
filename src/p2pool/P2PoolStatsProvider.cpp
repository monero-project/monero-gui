// Copyright (c) 2014-2026, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "P2PoolStatsProvider.h"

#include "cryptonote_config.h"

#include <QDebug>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

namespace {
     QString formatNumber(const QVariant &value) {
          return QLocale().toString(value.toLongLong());
     }

     QString formatHashrate(const QVariant &hashrateVar) {
          double hashrate = hashrateVar.toDouble();
          const QStringList units = {"H/s", "KH/s", "MH/s", "GH/s", "TH/s"};
          int unitIndex = 0;

          while (hashrate >= 1000 && unitIndex < units.size() - 1) {
               hashrate /= 1000;
               unitIndex++;
          }

          return QString("%1 %2")
               .arg(QLocale().toString(hashrate, 'f', 2))
               .arg(units[unitIndex]);
     }

     QString formatTimeRelative(const QVariant &timestampVar) {
          qint64 timestamp = timestampVar.toLongLong();
          qint64 current = QDateTime::currentSecsSinceEpoch();
          qint64 diff = current - timestamp;

          if (diff < 0) return "just now";

          qint64 days = diff / 86400;
          qint64 hours = (diff % 86400) / 3600;
          qint64 minutes = (diff % 3600) / 60;
          qint64 seconds = diff % 60;

          QStringList parts;
          if (days > 0) parts << QString("%1d").arg(days);
          if (hours > 0) parts << QString("%1h").arg(hours);
          if (minutes > 0) parts << QString("%1m").arg(minutes);
          if (seconds > 0 || parts.isEmpty()) parts << QString("%1s").arg(seconds);

          return parts.join(" ");
     }
}

P2PoolStatsProvider::P2PoolStatsProvider(
     const bool &started,
     const QString &p2poolPath,
     QObject *parent
     ) : QObject(parent)
       , m_started(started)
       , m_p2poolPath(p2poolPath)
{
     clear();
}

QVariantMap P2PoolStatsProvider::fetch(const QString &path)
{
     if(!m_started) {
          qWarning() << "cannot query p2pool without it started...";
          return {};
     }

     QFile file(m_p2poolPath + "/stats/" + path);
     if (!file.open(QIODevice::ReadOnly)) {
          qWarning() << "cannot open p2pool path for reading: " << path;
          return {};
     }

     QJsonDocument json = QJsonDocument::fromJson(file.readAll());
     if (!json.isObject()) {
          qWarning() << "cannot parse malformed p2pool data: " << path;
          return {};
     }

     return json.object().toVariantMap();
}

QVariantMap P2PoolStatsProvider::fetchLocal()
{
     QVariantMap map;

     QVariantMap local =
          fetch("local/miner");
     QVariantMap pool =
          fetch("pool/stats")["pool_statistics"].toMap();

     int uptime =
          local["time_running"].toInt();
     quint64 hashrate =
          local["current_hashrate"].toULongLong();
     quint64 total_hashes =
          local["total_hashes"].toULongLong();
     quint64 sidechain_height =
          pool["sidechainHeight"].toULongLong();

     if (total_hashes != 0 && sidechain_height != 0) {
          map.insert("hashrate", formatHashrate(hashrate));

          if (m_lastUpdate.isValid() && m_hashrate_ema15m.isValid() && m_hashrate_ema1h.isValid() && m_hashrate_ema24h.isValid()) {
               int secs =
                    m_lastUpdate.secsTo(QDateTime::currentDateTime());

               auto alpha = [&](int mins, qint64 secs) {
                    return 1.0 - std::exp(-static_cast<double>(secs) / static_cast<double>((mins * 60) / 3));
               };

               auto updateEMA = [&](QVariant& ema, int mins) {
                    double a =
                         alpha(mins, secs);
                    ema = (hashrate * a) + (ema.toDouble() * (1.0 - a));
               };

               updateEMA(m_hashrate_ema15m, 15);
               updateEMA(m_hashrate_ema1h, 60);
               updateEMA(m_hashrate_ema24h, 1440);
          } else {
               m_hashrate_ema15m = m_hashrate_ema1h = m_hashrate_ema24h = hashrate;
          }

          if (uptime < (15 * 60)) {
               map.insert("hashrate_ema15m", "waiting...");
          } else {
               map.insert("hashrate_ema15m", formatHashrate(m_hashrate_ema15m));
          }

          if (uptime < (60 * 60)) {
               map.insert("hashrate_ema1h", "waiting...");
          } else {
               map.insert("hashrate_ema1h", formatHashrate(m_hashrate_ema1h));
          }

          if (uptime < (1440 * 60)) {
               map.insert("hashrate_ema24h", "waiting...");
          } else {
               map.insert("hashrate_ema24h", formatHashrate(m_hashrate_ema24h));
          }

          map.insert("shares_found", formatNumber(shares_found));
          map.insert("shares_failed", formatNumber(shares_failed));
     }

     return map;
}

QVariantMap P2PoolStatsProvider::fetchPool()
{
     QVariantMap map;

     QVariantMap pool =
          fetch("pool/stats")["pool_statistics"].toMap();

     quint64 sidechain_height =
          pool["sidechainHeight"].toULongLong();
     quint64 last_block_found_time =
          pool["lastBlockFoundTime"].toLongLong();

     if (sidechain_height > 1) {
          map.insert("hashrate", formatHashrate(pool["hashRate"]));
          if (last_block_found_time != 0) {
               map.insert("last_block_found_time", formatTimeRelative(pool["lastBlockFoundTime"]));
          } else {
               map.insert("last_block_found_time", "not witnessed yet");
          }
          map.insert("pplns_window_size", formatNumber(pool["pplnsWindowSize"]));
     }

     return map;
}

QVariantMap P2PoolStatsProvider::fetchNetwork()
{
     QVariantMap map;

     QVariantMap network =
          fetch("network/stats");

     quint64 height =
          network["height"].toULongLong();
     quint64 difficulty =
          network["difficulty"].toULongLong();
     quint64 hashrate =
          (difficulty > 0) ? (difficulty / DIFFICULTY_TARGET_V2) : 0;

     if (height != 0) {
          map.insert("hashrate", formatHashrate(hashrate));
          map.insert("last_block_found_time", formatTimeRelative(network["timestamp"]));
     }

     return map;
}

QVariantMap P2PoolStatsProvider::fetchRaw()
{
     QVariantMap map;

     QStringList keys = {
          "stats_mod",
          "local/miner", "local/p2p", "local/stratum",
          "pool/stats",
          "network/stats"
     };

     for (const QString& key : keys) {
          QVariantMap data = fetch(key);
          if (!data.isEmpty()) {
               map.insert(key, data);
          }
     }

     return map;
}

void P2PoolStatsProvider::update()
{
     QVariantMap local =
          fetchLocal();
     QVariantMap pool =
          fetchPool();
     QVariantMap network =
          fetchNetwork();
     QVariantMap raw =
          fetchRaw();

     m_lastUpdate =
          QDateTime::currentDateTime();

     emit p2poolUpdateStats(local, pool, network, raw);
}

void P2PoolStatsProvider::clear()
{
     /* invalidate hashrate aggregates */
     m_hashrate_ema15m = QVariant();
     m_hashrate_ema1h = QVariant();
     m_hashrate_ema24h = QVariant();

     /* invalidate lastUpdate timestamp */
     m_lastUpdate = QDateTime();

     /* emit the update signal with empty maps to clear any listeners */
     emit p2poolUpdateStats(QVariantMap(), QVariantMap(), QVariantMap(), QVariantMap());
}
