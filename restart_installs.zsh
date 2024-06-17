#!/usr/bin/zsh

TMUX_VERSION="3.3a"
TMUX_SOURCE_URL="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"

install_tmux() {
    echo "Installing tmux from source..."
    wget -O tmux.tar.gz "${TMUX_SOURCE_URL}"
    tar -xzf tmux.tar.gz
    cd tmux-${TMUX_VERSION}
    ./configure
    make
    sudo make install
    cd ..
    rm -rf tmux-${TMUX_VERSION} tmux.tar.gz
}

install_tmux_plugins() {
    echo "Installing tmux plugins..."
    ~/.tmux/plugins/tpm/bin/install_plugins
}

check_tmux_installed() {
    if command -v tmux >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

main() {
    if ! check_tmux_installed; then
        install_tmux
        install_tmux_plugins\
    fi
}

main
