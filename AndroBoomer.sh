#!/usr/bin/env bash
set -e

############################
# Usage
############################
usage() {
  echo "Usage:"
  echo "  $0 -i                         Install required tools"
  echo "  $0 -p <package.name>          Fetch latest APK using apkeep"
  echo "  $0 -a <apk_file>              Use local APK file"
  echo ""
  echo "Run individual tools:"
  echo "  $0 -c                         Run apk-components-inspector"
  echo "  $0 -f                         Run frida-script-gen"
  echo "  $0 -d                         Run apkdig"
  echo "  $0 -l                         Run apkleaks"
  echo "  $0 -u                         Run apk2url"
  echo ""
  echo "Automation:"
  echo "  $0 -A                         Run ALL tools in parallel"
  exit 1
}

############################
# Helpers
############################
log() { echo "[*] $1"; }

check() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[-] $1 not installed"
    exit 1
  }
}

############################
# Install tools
############################
install_tools() {

  if ! command -v cargo >/dev/null 2>&1; then
    log "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y
    echo '. "$HOME/.cargo/env"' >> ~/.zshrc
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  install_py() {
    wget -q "$2" -O "$1"
    chmod +x "$1"
    sudo mv "$1" /usr/bin/
  }

  command -v apk-components-inspector.py >/dev/null || \
    install_py apk-components-inspector.py \
    https://github.com/thecybersandeep/apk-components-inspector/raw/refs/heads/main/apk-components-inspector.py

  command -v frida-script-gen.py >/dev/null || \
    install_py frida-script-gen.py \
    https://github.com/thecybersandeep/frida-script-gen/raw/refs/heads/main/frida-script-gen.py

  command -v apkdig >/dev/null || {
    wget -q https://release-assets.githubusercontent.com/github-production-release-asset/1022776967/ce872ca2-72cb-4e73-b332-7036e34fafef -O apkdig
    chmod +x apkdig
    sudo mv apkdig /usr/bin/
  }

  command -v apkeep >/dev/null || cargo install apkeep
  command -v apkleaks >/dev/null || pip3 install --user apkleaks

  command -v apk2url >/dev/null || {
    wget -q https://github.com/n0mi1k/apk2url/raw/refs/heads/main/install.sh
    wget -q https://github.com/n0mi1k/apk2url/raw/refs/heads/main/apk2url.sh
    chmod +x install.sh apk2url.sh
    ./install.sh
    sudo mv apk2url.sh /usr/bin/apk2url
  }

  log "Installation completed"
}

############################
# Prep
############################
prepare_dirs() {
  mkdir -p \
    apk-components-inspector_Output \
    frida-script-gen_Output \
    apkdig_Output \
    apkleaks_Output \
    apk2url_Output \
    fetched_apk
}

fetch_apk() {
  apkeep -a "$PACKAGE" fetched_apk
  APK=$(ls fetched_apk/*.apk | head -n1)
}

############################
# Tool functions
############################
run_components() {
  apk-components-inspector.py "$APK" \
    > apk-components-inspector_Output/output.txt
}

run_frida() {
  frida-script-gen.py "$APK" \
    > frida-script-gen_Output/output.js
}

run_apkdig() {
  apkdig -a "$APK" \
    > apkdig_Output/output.txt
}

run_apkleaks() {
  apkleaks -f "$APK" \
    > apkleaks_Output/output.txt
}

run_apk2url() {
  apk2url "$APK" \
    > apk2url_Output/output.txt
}

run_all() {
  prepare_dirs
  run_components &
  run_frida &
  run_apkdig &
  run_apkleaks &
  run_apk2url &
  wait
  log "All tools finished"
}

############################
# Args
############################
while getopts ":ip:a:cfdlAu" opt; do
  case "$opt" in
    i) install_tools; exit 0 ;;
    p) PACKAGE="$OPTARG" ;;
    a) APK="$OPTARG" ;;
    c) RUN_C=1 ;;
    f) RUN_F=1 ;;
    d) RUN_D=1 ;;
    l) RUN_L=1 ;;
    u) RUN_U=1 ;;
    A) RUN_ALL=1 ;;
    *) usage ;;
  esac
done

[ -z "$PACKAGE" ] && [ -z "$APK" ] && usage

prepare_dirs

if [ -n "$PACKAGE" ]; then
  check apkeep
  fetch_apk
fi

check apk-components-inspector.py
check frida-script-gen.py
check apkdig
check apkleaks
check apk2url

############################
# Execution
############################
[ "$RUN_C" ] && run_components
[ "$RUN_F" ] && run_frida
[ "$RUN_D" ] && run_apkdig
[ "$RUN_L" ] && run_apkleaks
[ "$RUN_U" ] && run_apk2url
[ "$RUN_ALL" ] && run_all
