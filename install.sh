#!/usr/bin/zsh

set -e

# Define variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
TMUX_VERSION="3.3a"
TMUX_SOURCE_URL="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
POWERLEVEL10K_REPO="https://github.com/romkatv/powerlevel10k.git"
LAZYVIM_REPO="https://github.com/LazyVim/starter"

install_dependencies() {
    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y \
        wget \
        tar \
        gcc \
        make \
        libevent-dev \
        ncurses-dev \
        git
}

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

install_powerlevel10k() {
    echo "Installing Powerlevel10k..."
    git clone --depth=1 "${POWERLEVEL10K_REPO}" "${HOME}/.powerlevel10k"
    echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}

install_lazyvim() {
    echo "Installing LazyVim..."
    git clone "${LAZYVIM_REPO}" "${CONFIG_DIR}/nvim"
}

setup_config() {
    echo "Setting up configuration directory..."
    mkdir -p "${CONFIG_DIR}"

    # Symlink configuration files
    ln -sf "${CONFIG_DIR}/.tmux.conf" "$HOME/.tmux.conf"

    # Source all .zsh files in the repository
    cat <<EOF >> "$HOME/.zshrc"
# Source custom Zsh configurations
for file in ${CONFIG_DIR}/*.zsh; do
    source \$file
done
EOF
}

# Main function
main() {
    install_dependencies
    install_tmux
    setup_config
    install_powerlevel10k
    install_lazyvim
    echo "Setup completed successfully."
}

main