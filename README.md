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

### Using eselect repository

    # if not already installed
    emerge app-eselect/eselect-repository
    # ..then add the overlay 
    eselect repository add kubler git https://github.com/edannenberg/kubler-overlay.git
    emerge --sync

## Ebuild Development with Kubler

Can be used for any Gentoo Portage overlay, example is for this repo:

1. Create a new namespace, let's call it `edev`

```
    $ kubler new namespace edev
```

2. Create a new builder, choose `kubler/bob` as `IMAGE_PARENT`:

```
    $ kubler new builder edev/bob
```

Edit the new builder's `build.sh` and add your overlay:

```
configure_builder() {
    # we overwrite this with a local host mount later, but this takes care of the initial overlay setup in the builder for us
    add_overlay kubler https://github.com/edannenberg/kubler-overlay.git
    # just for convenience
    echo 'cd /var/db/repos/kubler' >> ~/.bashrc
}
```

3. Create a new image, let's call it `bench`, use `kubler/bash` as `IMAGE_PARENT`:

```
    $ kubler new image edev/bench
```

Then edit the new image's `build.conf` and configure the builder and overlay path you want to mount in the builder:

```
    BUILDER="edev/bob"
    BUILDER_MOUNTS=("/home/foo/projects/kubler-overlay:/var/db/repos/kubler")
```

4. Start an interactive build container and get tinkering:

```
    $ kubler build -i edev/bench
    # ebuild dev-lang/foo/foo-0.4.0.ebuild manifest merge 
```
