# libguestfs

This is a very hacked-up build of (some of) [libguestfs](https://libguestfs.org/).

This is currently built on Ubuntu 20.04 using a libguestfs release tarball.

This produces three packages:

- `optpython3.10-guestfs` - This is the guestfs Python extension, built for [Caketop's Python](../python/).
- `guestfish1.48` - This is [guestfish](https://libguestfs.org/guestfish.1.html), built at the same time as the Python extension.
- `libguestfs1.48-fixed-appliance` - This contains an archive of a pre-built binary appliance (i.e. a virtual machine image) for use with the above packages.

In these builds, `libguestfs` has been made into a static library and embedded into the Python extension and `guestfish` binary. These packages still have shared library dependencies, but `libguestfs` is not among them.

These packages require a working [QEMU](https://www.qemu.org/) installation. There is not one currently provided; either install the `qemu-system-x86` package from the Ubuntu 20.04 repositories, or build your own. These packages do not depend on the `qemu-system-x86` package in case you want to build your own.

These packages are available in the [bootleg packages apt repository](https://packagecloud.io/caketop/bootleg-packages).

## Using

1. Start with an Ubuntu 20.04 system or container.
2. Install your preferred flavor of QEMU.
3. Install `optpython3.10-guestfs` and/or `guestfish1.48`.
4. Install the `libguestfs1.48-fixed-appliance` package.
5. Extract the tarball you'll find `/usr/lib/libguestfs-fixed-appliance` to somewhere convenient. This will look large, but don't worry; the disk image is a sparse file.
6. Set the `LIBGUESTFS_PATH` environment variable to the path where you extracted the tarball, i.e. `export LIBGUESTFS_PATH=/path/to/my/appliance`
7. You may now `import guestfs` into your Python script and/or use `guestfish`.
