kubler-overlay
==============

[Gentoo](https://www.gentoo.org/get-started/about/) ebuild overlay used by [Kubler](https://github.com/edannenberg/kubler).
This is somewhat container centric, packages with active `minimal` use flag probably don't have very well tested init
scripts. Feel free to open an issue or, even better, a PR. :yum:

## Installation

### Manually

The repo comes with a ready [repos.conf](https://wiki.gentoo.org/wiki//etc/portage/repos.conf) file you just need to add
to your `/etc/portage/repos.conf/` dir:

    curl -sL https://raw.githubusercontent.com/edannenberg/kubler-overlay/master/kubler.conf > /etc/portage/repos.conf/kubler.conf
    emerge --sync

### Using layman

    layman -o https://raw.githubusercontent.com/edannenberg/kubler-overlay/master/overlay.xml -f -a kubler
