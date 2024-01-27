# Monero GUI

Copyright (c) 2014-2022, The Monero Project

## Table of Contents
  * [Development resources](#development-resources)
  * [Vulnerability response](#vulnerability-response)
  * [Introduction](#introduction)
  * [About this project](#about-this-project)
  * [Supporting the project](#supporting-the-project)
  * [License](#license)
  * [Translations](#translations)
  * [Installing the Monero GUI from a package](#installing-the-monero-gui-from-a-package)
  * [Compiling the Monero GUI from source](#compiling-the-monero-gui-from-source)

## Development resources

- Web: [getmonero.org](https://getmonero.org)
- Mail: [dev@getmonero.org](mailto:dev@getmonero.org)
- Github: [https://github.com/monero-project/monero-gui](https://github.com/monero-project/monero-gui)
- IRC: [#monero-gui on Libera](irc://irc.libera.chat/#monero-gui)
- Translation platform (Weblate): [translate.getmonero.org](https://translate.getmonero.org)
- UI Design: [Monero-GUI on Figma](https://www.figma.com/file/DplJ2DDQfIKiuRvolHX2hN/Monero-GUI)

## Vulnerability response

- Our [Vulnerability Response Process](https://github.com/monero-project/meta/blob/master/VULNERABILITY_RESPONSE_PROCESS.md) encourages responsible disclosure
- We are also available via [HackerOne](https://hackerone.com/monero)

## Introduction

Monero is a private, secure, untraceable, decentralised digital currency. You are your bank, you control your funds, and nobody can trace your transfers unless you allow them to do so.

**Privacy:** Monero uses a cryptographically sound system to allow you to send and receive funds without your transactions being easily revealed on the blockchain (the ledger of transactions that everyone has). This ensures that your purchases, receipts, and all transfers remain absolutely private by default.

**Security:** Using the power of a distributed peer-to-peer consensus network, every transaction on the network is cryptographically secured. Individual wallets have a 25 word mnemonic seed that is only displayed once, and can be written down to backup the wallet. Wallet files are encrypted with a passphrase to ensure they are useless if stolen.

**Untraceability:** By taking advantage of ring signatures, a special property of a certain type of cryptography, Monero is able to ensure that transactions are not only untraceable, but have an optional measure of ambiguity that ensures that transactions cannot easily be tied back to an individual user or computer.

## About this project

This is the GUI for the [core Monero implementation](https://github.com/monero-project/monero). It is open source and completely free to use without restrictions, except for those specified in the license agreement below. There are no restrictions on anyone creating an alternative implementation of Monero that uses the protocol and network in a compatible manner.

As with many development projects, the repository on Github is considered to be the "staging" area for the latest changes. Before changes are merged into that branch on the main repository, they are tested by individual developers in their own branches, submitted as a pull request, and then subsequently tested by contributors who focus on testing and code reviews. That having been said, the repository should be carefully considered before using it in a production environment, unless there is a patch in the repository for a particular show-stopping issue you are experiencing. It is generally a better idea to use a tagged release for stability.

## Supporting the project

Monero is a 100% community-sponsored endeavor. If you want to join our efforts, the easiest thing you can do is support the project financially. Both Monero and Bitcoin donations can be made to **donate.getmonero.org** if using a client that supports the [OpenAlias](https://openalias.org) standard.

The Monero donation address is: `888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H` (viewkey: `f359631075708155cc3d92a32b75a7d02a5dcf27756707b47a2b31b21c389501`)

The Bitcoin donation address is: `1KTexdemPdxSBcG55heUuTjDRYqbC5ZL8H`

GUI development funding and/or some supporting services are also graciously provided by [sponsors](https://www.getmonero.org/community/sponsorships/):

[<img width="150" src="https://www.getmonero.org/img/sponsors/tarilabs.png"/>](https://tarilabs.com/)
[<img width="150" src="https://www.getmonero.org/img/sponsors/globee.png"/>](https://globee.com/)
[<img width="150" src="https://www.getmonero.org/img/sponsors/symas.png"/>](https://symas.com/)
[<img width="150" src="https://www.getmonero.org/img/sponsors/forked_logo.png"/>](http://www.forked.net/)
[<img width="150" src="https://www.getmonero.org/img/sponsors/macstadium.png"/>](https://www.macstadium.com/)

There are also several mining pools that kindly donate a portion of their fees, [a list of them can be found on our Bitcointalk post](https://bitcointalk.org/index.php?topic=583449.0).

## License

See [LICENSE](LICENSE).

## Translations

Do you speak a second language and would like to help translate the Monero GUI? Check out Weblate, our localization platform, at [translate.getmonero.org](https://translate.getmonero.org/). Choose the language and suggest a translation for a string or review an existing one. The Localization Workgroup made [a guide with step-by-step instructions](https://github.com/monero-ecosystem/monero-translations/blob/master/weblate.md) for Weblate.

If you need help/support or any info you can contact the localization workgroup on the IRC channel #monero-translations (relayed on [Matrix](https://matrix.to/#/!BKMbQLMDzHKzmtrBfg:matrix.org?via=monero.social&via=matrix.org&via=libera.chat)) or by email at translate[at]getmonero[dot]org. For more info about the Localization workgroup: [github.com/monero-ecosystem/monero-translations](https://github.com/monero-ecosystem/monero-translations)

Status of the translations:  

<a href="https://translate.getmonero.org/engage/monero/?utm_source=widget">
<img src="https://translate.getmonero.org/widgets/monero/-/gui-wallet/horizontal-auto.svg" alt="Translation status" />
</a>

## Installing the Monero GUI from a package

Packages are available for
* Arch Linux: [monero-gui](https://archlinux.org/packages/extra/x86_64/monero-gui/)
* Void Linux: `xbps-install -S monero-gui`
* Flatpak: [Monero GUI](https://flathub.org/apps/details/org.getmonero.Monero)
* GuixSD: `guix package -i monero-gui`
* macOS (homebrew): `brew install --cask monero-wallet`

Packaging for your favorite distribution would be a welcome contribution!

## Compiling the Monero GUI from source

See [BUILDING.md](BUILDING.md).
