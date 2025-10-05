# Bazel rules to support a debian rootfs

[![Test status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/test.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/test.yml)
[![Publish BCR status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish-bcr.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish-bcr.yml)
[![Publish status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish.yml)
[![Tag and Release status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/tag-and-release.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/tag-and-release.yml)

The idea of this repository is to provide a [hermetic, ephemeral and
reproducible][her] repository of prebuilt binaries, which can then be brought
into bazel builds to remove the dependence on local binary installations.

This is otherwise a difficult task. Making a hermetic bazel build involves
painstakingly bringing in each needed binary one at a time. Often, this means
descending into the rats nest of dependencies and having to bring them all in.
One can convince themselves that this approach is then equivalent to rebuilding
an entire software repository from scratch. Something that we should avoid
doing if we can help it.  And something that presents a significant barrier to
entry for bazel builds, and one that is best avoided if possible.

Instead, we use existing [`rules_distroless`][rd] and [`rules_oci`][ro] to
bring in packages from a Debian repository. The rules that achieve this are all
confined within the bazel package [`//images`](./images/BUILD.bazel).

The second step is bringing the actual binaries into the bazel build process for
reuse. This is done in [`//bin`](./bin/BUILD.bazel). If you look at the [example
script for ghdl](./bin/ghdl.sh), you will see the complication: since the Debian
rootfs is not necessarily compatible with the host distribution, we have to
create an environment that allows execution of "foreign" binaries on your machine.
This is done by creatively using `LD_LIBRARY_PATH`, `PATH` and other needed
environment variables on a per-binary basis. Getting the incantation just right
for `ghdl` to operate properly makes me think that a more robust approach should
be used instead, if we were to generalize the approach.

[rd]: https://registry.bazel.build/modules/rules_distroless
[ro]: https://registry.bazel.build/modules/rules_oci

[her]: https://hdlfactory.com/note/2024/05/01/hermetic-ephemeral-reproducible-builds-her/

### Prerequisites

* `bazel` installation via [`bazelisk`][aa]. I recommend downloading `bazelisk`
  and placing it somewhere in your `$PATH` under the name `bazel`.

Everything else will be downloaded for use the first time you run the build.

[aa]: https://hdlfactory.com/note/2024/08/24/bazel-installation-via-the-bazelisk-method/

## Examples

In general, see [integration/](integration/) for example use.

### Sample use: `ghdl_verilog`


```
cd integration && bazel build //... && cat bazel-bin/verilog/lib.v
```

To see how it builds a library, run this:

```
cd integration && bazel build //:lib
```

## Notes

* Only Linux host and target are supported for now, although it should be
  straightforward (but not necessarily trivial) to add support for other archs.

* When updating `//image/rootfs_definition.yaml`, make sure to turn off the lock
  file. This allows the definition to be actually updated. Otherwise, adding a
  new package, for example, will *not* be reflected in the built rootfs.

## References

* https://github.com/filmil/bazel_rules_ghdl: a repository that started all of
  this.
* Attempt #1, using docker: https://hdlfactory.com/post/2025/02/11/bazel-rules-for-build-in-docker-or-bid/
* Attempt #2, using Nix: https://hdlfactory.com/post/2024/04/20/nix-bazel-%EF%B8%8F/
