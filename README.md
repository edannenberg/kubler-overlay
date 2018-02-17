kubler-overlay
==============

Gentoo ebuild overlay used by [Kubler](https://github.com/edannenberg/kubler).

## Installation

### Manually via [repos.conf](https://wiki.gentoo.org/wiki//etc/portage/repos.conf)

You can setup this overlay by running this one-liner:

    curl -sL https://raw.githubusercontent.com/edannenberg/kubler-overlay/master/kubler.conf > /etc/portage/repos.conf/kubler.conf
    

### Using layman

    layman -o https://raw.githubusercontent.com/edannenberg/kubler-overlay/master/overlay.xml -f -a kubler
