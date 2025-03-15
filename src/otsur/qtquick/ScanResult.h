// SPDX-License-Identifier: BSD-3-Clause
// SPDX-FileCopyrightText: 2020-2024 The Monero Project

#ifndef CODE_SCAN_RESULT_H
#define CODE_SCAN_RESULT_H

#include <QString>

class ScanResult
{
public:
    explicit ScanResult(const std::string &text, bool isValid)
        : m_text(QString::fromStdString(text))
        , m_valid(isValid){}
    
    [[nodiscard]] QString text() const { return m_text; }
    [[nodiscard]] bool isValid() const { return m_valid; }
    
private:
    QString m_text = "";
    bool m_valid = false;
};

#endif // CODE_SCAN_RESULT_H
