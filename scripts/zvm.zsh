#!/usr/bin/zsh
setopt null_glob

cmd="$1"
ZIG_INSTALL_DIR="$HOME/.zvm/versions/"
ZIG_BIN_DIR="$HOME/.zvm/bin/"
ZIG_SYMLINK="$ZIG_BIN_DIR/zig"

if [[ ! -d "$ZIG_INSTALL_DIR" ]]; then
  mkdir -p "$ZIG_INSTALL_DIR"
fi

if [[ ! -d "$ZIG_BIN_DIR" ]]; then
  mkdir -p "$ZIG_BIN_DIR"
fi

function install() {
  install_version=$1
  remote_versions=$(get_remote_versions | jq -r --arg version "$install_version" '.[] | select(.version == $version) | .link')
  tar_name=$(basename $remote_versions)
  curl -O --output-dir /tmp $remote_versions
  mkdir "$ZIG_INSTALL_DIR/$install_version"
  tar xf "/tmp/$tar_name" -C $ZIG_INSTALL_DIR/$install_version --strip-components=1
}

function zig_symlink_exists() {
  [[ -L "$ZIG_SYMLINK" && ! -e "$ZIG_SYMLINK" ]]
}

function version_is_valid() {
  version=$1
  if [[ ! -d "$ZIG_INSTALL_DIR/$version" ]]; then
    echo "Version $version is not installed"
    return 1
  fi
  if [[ ! -e "$ZIG_INSTALL_DIR/$version/zig" ]]; then
    echo "No zig executable for version $version"
  fi
}

function lookup_zig_dirs() {
  for path_name in $ZIG_INSTALL_DIR*; do
    folder_name="${path_name##*/}"
    print $folder_name
  done
}

function get_remote_versions() {
  curl -s https://ziglang.org/download/index.json | jq '
    to_entries
    | map (
        select(.value["x86_64-linux"] != null)
        | {
            version: .key,
            link: .value."x86_64-linux".tarball
        }
    )
  '
}

case $cmd in
  ls)
    lookup_zig_dirs
    ;;
  ls-remote)
    get_remote_versions
    ;;
  install)
    install $2
    ;;
  version)
    if zig_symlink_exists; then
      . $ZIG_SYMLINK version
    else
      echo "No zig version found"
    fi
    ;;
  use)
    if version_is_valid $2; then
      ln -s -f $ZIG_INSTALL_DIR/$2/zig $ZIG_SYMLINK
    fi
    ;;
  rmall)
    rm -rf $ZIG_INSTALL_DIR/*
    zig_symlink_exists && rm $ZIG_SYMLINK
    ;;
  *)
    echo "unknown command $cmd"
    ;;
esac

