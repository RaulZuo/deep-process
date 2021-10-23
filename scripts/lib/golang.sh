#!/usr/bin/env bash

# Copyright 2020 Lingfei Kong <colin404@foxmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2034 # Variables sourced in other scripts.

# The server platform we are building on.
readonly DEEP_SUPPORTED_SERVER_PLATFORMS=(
  linux/amd64
  linux/arm64
)

# If we update this we should also update the set of platforms whose standard
# library is precompiled for in build/build-image/cross/Dockerfile
readonly DEEP_SUPPORTED_CLIENT_PLATFORMS=(
  linux/amd64
  linux/arm64
)

# The set of server targets that we are only building for Linux
# If you update this list, please also update build/BUILD.
deep::golang::server_targets() {
  local targets=(
    deep-apiserver
    deep-authz-server
    deep-pump
  )
  echo "${targets[@]}"
}

IFS=" " read -ra DEEP_SERVER_TARGETS <<< "$(deep::golang::server_targets)"
readonly DEEP_SERVER_TARGETS
readonly DEEP_SERVER_BINARIES=("${DEEP_SERVER_TARGETS[@]##*/}")

# The set of server targets we build docker images for
deep::golang::server_image_targets() {
  # NOTE: this contains cmd targets for deep::build::get_docker_wrapped_binaries
  local targets=(
    cmd/deep-apiserver
    cmd/deep-authz-server
    cmd/deep-pump
  )
  echo "${targets[@]}"
}

IFS=" " read -ra DEEP_SERVER_IMAGE_TARGETS <<< "$(deep::golang::server_image_targets)"
readonly DEEP_SERVER_IMAGE_TARGETS
readonly DEEP_SERVER_IMAGE_BINARIES=("${DEEP_SERVER_IMAGE_TARGETS[@]##*/}")

# ------------
# NOTE: All functions that return lists should use newlines.
# bash functions can't return arrays, and spaces are tricky, so newline
# separators are the preferred pattern.
# To transform a string of newline-separated items to an array, use deep::util::read-array:
# deep::util::read-array FOO < <(deep::golang::dups a b c a)
#
# ALWAYS remember to quote your subshells. Not doing so will break in
# bash 4.3, and potentially cause other issues.
# ------------

# Returns a sorted newline-separated list containing only duplicated items.
deep::golang::dups() {
  # We use printf to insert newlines, which are required by sort.
  printf "%s\n" "$@" | sort | uniq -d
}

# Returns a sorted newline-separated list with duplicated items removed.
deep::golang::dedup() {
  # We use printf to insert newlines, which are required by sort.
  printf "%s\n" "$@" | sort -u
}

# Depends on values of user-facing DEEP_BUILD_PLATFORMS, DEEP_FASTBUILD,
# and DEEP_BUILDER_OS.
# Configures DEEP_SERVER_PLATFORMS and DEEP_CLIENT_PLATFORMS, then sets them
# to readonly.
# The configured vars will only contain platforms allowed by the
# DEEP_SUPPORTED* vars at the top of this file.
declare -a DEEP_SERVER_PLATFORMS
declare -a DEEP_CLIENT_PLATFORMS
deep::golang::setup_platforms() {
  if [[ -n "${DEEP_BUILD_PLATFORMS:-}" ]]; then
    # DEEP_BUILD_PLATFORMS needs to be read into an array before the next
    # step, or quoting treats it all as one element.
    local -a platforms
    IFS=" " read -ra platforms <<< "${DEEP_BUILD_PLATFORMS}"

    # Deduplicate to ensure the intersection trick with deep::golang::dups
    # is not defeated by duplicates in user input.
    deep::util::read-array platforms < <(deep::golang::dedup "${platforms[@]}")

    # Use deep::golang::dups to restrict the builds to the platforms in
    # DEEP_SUPPORTED_*_PLATFORMS. Items should only appear at most once in each
    # set, so if they appear twice after the merge they are in the intersection.
    deep::util::read-array DEEP_SERVER_PLATFORMS < <(deep::golang::dups \
        "${platforms[@]}" \
        "${DEEP_SUPPORTED_SERVER_PLATFORMS[@]}" \
      )
    readonly DEEP_SERVER_PLATFORMS

    deep::util::read-array DEEP_CLIENT_PLATFORMS < <(deep::golang::dups \
        "${platforms[@]}" \
        "${DEEP_SUPPORTED_CLIENT_PLATFORMS[@]}" \
      )
    readonly DEEP_CLIENT_PLATFORMS

  elif [[ "${DEEP_FASTBUILD:-}" == "true" ]]; then
    DEEP_SERVER_PLATFORMS=(linux/amd64)
    readonly DEEP_SERVER_PLATFORMS
    DEEP_CLIENT_PLATFORMS=(linux/amd64)
    readonly DEEP_CLIENT_PLATFORMS
  else
    DEEP_SERVER_PLATFORMS=("${DEEP_SUPPORTED_SERVER_PLATFORMS[@]}")
    readonly DEEP_SERVER_PLATFORMS

    DEEP_CLIENT_PLATFORMS=("${DEEP_SUPPORTED_CLIENT_PLATFORMS[@]}")
    readonly DEEP_CLIENT_PLATFORMS
  fi
}

deep::golang::setup_platforms

# The set of client targets that we are building for all platforms
# If you update this list, please also update build/BUILD.
readonly DEEP_CLIENT_TARGETS=(
  deepctl
)
readonly DEEP_CLIENT_BINARIES=("${DEEP_CLIENT_TARGETS[@]##*/}")

readonly DEEP_ALL_TARGETS=(
  "${DEEP_SERVER_TARGETS[@]}"
  "${DEEP_CLIENT_TARGETS[@]}"
)
readonly DEEP_ALL_BINARIES=("${DEEP_ALL_TARGETS[@]##*/}")

# Asks golang what it thinks the host platform is. The go tool chain does some
# slightly different things when the target platform matches the host platform.
deep::golang::host_platform() {
  echo "$(go env GOHOSTOS)/$(go env GOHOSTARCH)"
}

# Ensure the go tool exists and is a viable version.
deep::golang::verify_go_version() {
  if [[ -z "$(command -v go)" ]]; then
    deep::log::usage_from_stdin <<EOF
Can't find 'go' in PATH, please fix and retry.
See http://golang.org/doc/install for installation instructions.
EOF
    return 2
  fi

  local go_version
  IFS=" " read -ra go_version <<< "$(go version)"
  local minimum_go_version
  minimum_go_version=go1.13.4
  if [[ "${minimum_go_version}" != $(echo -e "${minimum_go_version}\n${go_version[2]}" | sort -s -t. -k 1,1 -k 2,2n -k 3,3n | head -n1) && "${go_version[2]}" != "devel" ]]; then
    deep::log::usage_from_stdin <<EOF
Detected go version: ${go_version[*]}.
DEEP requires ${minimum_go_version} or greater.
Please install ${minimum_go_version} or later.
EOF
    return 2
  fi
}

# deep::golang::setup_env will check that the `go` commands is available in
# ${PATH}. It will also check that the Go version is good enough for the
# DEEP build.
#
# Outputs:
#   env-var GOBIN is unset (we want binaries in a predictable place)
#   env-var GO15VENDOREXPERIMENT=1
#   env-var GO111MODULE=on
deep::golang::setup_env() {
  deep::golang::verify_go_version

  # Unset GOBIN in case it already exists in the current session.
  unset GOBIN

  # This seems to matter to some tools
  export GO15VENDOREXPERIMENT=1

  # Open go module feature
  export GO111MODULE=on

  # This is for sanity.  Without it, user umasks leak through into release
  # artifacts.
  umask 0022
}
