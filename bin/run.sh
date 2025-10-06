#! /usr/bin/env bash
# vi: ft=bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# For some reason rlocation gives up if it doesn't find the repo.
_repo_name="$(runfiles_current_repository)/"
if [[ "${_repo_name}" == "/" ]]; then
  _repo_name="${TEST_REPOSITORY_NAME:-bazel_debian_rootfs}/"
fi
_rootfs_dir="$(rlocation ${_repo_name}image/rootfs)"
if [[ ${_rootfs_dir} == "/" ]]; then
  echo "$0: could not find rootfs: ${_rootfs_dir}"
  exit 1
fi

readonly _gotopt2_runfiles_path="multitool/tools/gotopt2/gotopt2"
#readonly _gotopt2_runfiles_path="rules_multitool++multitool+multitool/tools/gotopt2/gotopt2"
readonly _gotopt_binary="$(rlocation ${_gotopt2_runfiles_path})"
if [[ "${_gotopt_binary}" == "" ]]; then
  echo ERROR: gotopt2 binary not found
  exit 240
fi

GOTOPT2_OUTPUT=$($_gotopt_binary "${@}" <<EOF
flags:
- name: "binary-path"
  type: string
  help: "The full path of the binary to start"
EOF
)
if [[ "$?" == "11" ]]; then
  # When --help option is used, gotopt2 exits with code 11.
  exit 1
fi

# Evaluate the output of the call to gotopt2, shell vars assignment is here.
eval "${GOTOPT2_OUTPUT}"

if [[ "${gotopt2_binary_path}" == "" ]]; then
  echo "ERROR: flag --binary-path=... is required"
  exit 1
fi

readonly _ld_preload_path="${_rootfs_dir}/lib/x86_64-linux-gnu:${_rootfs_dir}/usr/lib/x86_64-linux-gnu"
readonly _path="${_rootfs_dir}/bin:${_rootfs_dir}/usr/bin:${_rootfs_dir}/usr/lib/ghdl/gcc"
readonly _ld_so="${_rootfs_dir}/lib64/ld-linux-x86-64.so.2"

env \
  LD_LIBRARY_PATH="${_ld_preload_path}" \
  PATH="${_path}" \
    "${_ld_so}" \
      "${_rootfs_dir}${gotopt2_binary_path}" \
      ${gotopt2_args__[@]}

