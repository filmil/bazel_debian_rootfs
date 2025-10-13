
def _rootfs_impl(ctx):
    name = ctx.attr.name
    xrootfs = ctx.executable._xrootfs
    image_tar = ctx.attr.image_tar.files.to_list()[0]

    output_dir = ctx.actions.declare_directory(name)

    inputs = [image_tar]
    outputs = [output_dir]

    args = ctx.actions.args()

    args.add("--image-tar", image_tar.path)
    args.add("--rootfs-dir", output_dir.path)
    args.add_all(ctx.attr.markers, before_each = "--marker")
    args.add_all(ctx.attr.to_remove, before_each="--rm")

    ctx.actions.run(
        inputs = inputs,
        outputs = outputs,
        mnemonic = "xrootfs",
        progress_message = "Extracting rootfs",
        executable = xrootfs,
        arguments = [args],
    )

    return [
        DefaultInfo(files=depset([output_dir])),
    ]


rootfs = rule(
    implementation = _rootfs_impl,
    doc = """Extract a rootfs from an OCI container image.

    The resulting rootfs directory can be used to invoke binaries from,
    for example.
    """,
    attrs = {
        "image_tar": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The image archive to extract from. Usually you need to build it first.",
        ),
        "to_remove": attr.string_list(
            doc = "file paths, relative to rootfs, to remove",
        ),
        "markers": attr.string_list(
            doc = "file paths, relative to rootfs, to add",
        ),
        "_xrootfs": attr.label(
            default = "@multitool//tools/xrootfs",
            executable = True,
            cfg = "host",
        ),
    },

)
