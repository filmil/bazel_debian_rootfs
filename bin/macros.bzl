load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

_BINARY_SCRIPT="""
#! /usr/bin/env bash
# vi: ft=bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${{RUNFILES_DIR:-/dev/null}}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  {{ echo>&2 "ERROR: cannot find $f"; exit 1; }}; f=; set -e
# --- end runfiles.bash initialization v3 ---

# For some reason rlocation gives up if it doesn't find the repo.
_repo_name="$(runfiles_current_repository)/"
if [[ "${{_repo_name}}" == "/" ]]; then
  _repo_name="${{TEST_REPOSITORY_NAME:-bazel_rootfs}}/"
fi
if [[ "${{_repo_name}}" == "/" ]]; then
  echo ERROR: cannot find repository.
fi

_run_binary="$(rlocation ${{_repo_name}}bin/run.sh)"
if [[ ${{_run_binary}} == "" ]]; then
  echo "$0: could not find binary: ${{_run_binary}}"
  exit 1
fi

"${{_run_binary}}" --binary-path="{BINARY_NAME_HERE}" -- "${{@}}"
"""

_TEST_SCRIPT = """#! /usr/bin/env bash

set -euo pipefail


# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set -e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${{RUNFILES_DIR:-/dev/null}}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  {{ echo>&2 "ERROR: cannot find $f"; exit 1; }}; f=; set -e
# --- end runfiles.bash initialization v3 ---

readonly _bin="$(rlocation "_main{BINARY_NAME_HERE}")"

"${{_bin}}" --help

"""

def sh_binary_and_test(name, binary_cmd=None, test_cmd=None, **kwargs):
    """
    Generates a starter script for a command named `name`, and a basic test.

    Args:
    - `name` (string): the name of the binary, will become target `//bin:<name>`
    - `binary_cmd` (string): the full path in the rootfs of the binary to invoke
      Sometimes this is not `/usr/bin/name` but something else.
    - `test_cmd` the name of the generated script, in case this is something
      special.
    """
    binary_script_name = "{}_run.sh".format(name)
    binary_cmd = binary_cmd or "/usr/bin/{}".format(name)
    write_file(
        name = "{}_write".format(name),
        out =  binary_script_name,
        content = _BINARY_SCRIPT.format(BINARY_NAME_HERE=binary_cmd).split('\n'),
        is_executable = True,
    )
    sh_binary(
        name = name,
        srcs = [ binary_script_name ],
        data = [
            Label("//image:rootfs"),
            Label("@rules_shell//shell/runfiles"),
            Label("@bazel_tools//tools/bash/runfiles"),
            Label("//bin:run"),
        ],
    )
    test_script_name = "{}_test.sh".format(name)
    test_cmd = test_cmd or "/bin/{}".format(name)
    write_file(
        name = "{}_test_write".format(name),
        out =  test_script_name,
        content = _TEST_SCRIPT.format(BINARY_NAME_HERE=test_cmd).split('\n'),
        is_executable = True,
    )
    sh_test(
        name = "{}_test".format(name),
        srcs = [
            test_script_name,
        ],
        data = [
            ":{}".format(name),
            "@rules_shell//shell/runfiles",
            "@bazel_tools//tools/bash/runfiles",
        ],
        size = "small",
    )

