#!/usr/bin/zsh

DEPS=("curl" "jq")
INSTALL_DIR="$HOME/.local/bin/"

for dep in $DEPS; do
  if [[ ! -e $(which $dep) ]]; then
    "ERROR: $dep is not installed. Qutting..."
    exit 1;
  fi
done


if [[ ! -d $INSTALL_DIR ]]; then
  echo "Creating install path $INSTALL_DIR, add to your PATH var"
  mkdir -p "$INSTALL_DIR"
fi

for script in scripts/*; do
  basename_script=$(basename "$script")
  basename_script_sans_ext=${basename_script%.*}
  cp -f "$script" "$INSTALL_DIR/$basename_script_sans_ext"
  chmod +x "$INSTALL_DIR/$basename_script_sans_ext"
done

