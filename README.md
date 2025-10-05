# Bazel rules to support a debian rootfs

[![Test status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/test.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/test.yml)
[![Publish BCR status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish-bcr.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish-bcr.yml)
[![Publish status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/publish.yml)
[![Tag and Release status](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/tag-and-release.yml/badge.svg)](https://github.com/filmil/bazel_debian_rootfs/actions/workflows/tag-and-release.yml)


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

## References

* https://github.com/filmil/bazel_rules_ghdl: a repository that started all of
  this.
* Attempt #1, using docker: https://hdlfactory.com/post/2025/02/11/bazel-rules-for-build-in-docker-or-bid/
* Attempt #2, using Nix: https://hdlfactory.com/post/2024/04/20/nix-bazel-%EF%B8%8F/
