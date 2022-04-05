# ostree

This is a backport of a newer version of [ostree](https://ostreedev.github.io/ostree/) to Ubuntu 20.04.

The sources are taken from a Debian snapshot of sid.

This `ostree` has been built with `--with-builtin-grub2-mkconfig` to solve a problem I no longer remember well enough to articulate.

It is available in the [bootleg packages apt repository](https://packagecloud.io/caketop/bootleg-packages) as `ostree` - it upgrades/replaces the `ostree` that comes with 20.04.
