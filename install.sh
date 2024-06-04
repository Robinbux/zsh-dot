#!/usr/bin/zsh

#set -e

# Define variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
TMUX_VERSION="3.3a"
TMUX_SOURCE_URL="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
POWERLEVEL10K_REPO="https://github.com/romkatv/powerlevel10k.git"
LAZYVIM_REPO="https://github.com/LazyVim/starter"
OH_MY_ZSH_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
OH_MY_ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
ZSH_AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
TPM_REPO="https://github.com/tmux-plugins/tpm"

# Set with cargo packages
CARGO_PACKAGES=(
    "eza"
    "bat"
    "fnm"
)

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
        git \
        fzf \
        ripgrep \
        fd-find
}

install_rust() {
    echo "Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
}

install_cargo_packages() {
    echo "Installing Cargo packages..."
    for package in "${CARGO_PACKAGES[@]}"; do
        cargo install "$package"
    done

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

install_tpm() {
    echo "Installing TPM (Tmux Plugin Manager)..."
    git clone "${TPM_REPO}" ~/.tmux/plugins/tpm
}

install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    # Backup existing .zshrc
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Restore previous .zshrc and reapply necessary changes
    if [ -f "$HOME/.zshrc.bak" ]; then
        tail -n +2 "$HOME/.zshrc" >> "$HOME/.zshrc.bak"
        mv "$HOME/.zshrc.bak" "$HOME/.zshrc"
    fi
}

install_oh_my_zsh_plugins() {
    echo "Installing Oh My Zsh plugins..."
    git clone --depth=1 "${ZSH_AUTOSUGGESTIONS_REPO}" "${OH_MY_ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    git clone --depth=1 "${ZSH_SYNTAX_HIGHLIGHTING_REPO}" "${OH_MY_ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    # Enable the plugins in .zshrc
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
}

install_powerlevel10k() {
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}

install_lazyvim() {
    echo "Installing LazyVim..."
    git clone "${LAZYVIM_REPO}" "${CONFIG_DIR}/nvim"
}

setup_config() {
    echo "Setting up configuration directory..."
    mkdir -p "${SCRIPT_DIR}"

    # Remove old conf if exists
    rm ~/.tmux.conf

    cp "${SCRIPT_DIR}/.tmux.conf" "$HOME/.tmux.conf"

    # Symlink configuration files
    #ln -sf "${SCRIPT_DIR}/.tmux.conf" "$HOME/.tmux.conf"

    # Source all .zsh files in the repository
    cat <<EOF >> "$HOME/.zshrc"
# Source custom Zsh configurations
for file in ${SCRIPT_DIR}/*.zsh; do
    source \$file
done
EOF
}

install_tmux_plugins() {
    echo "Installing tmux plugins..."
    ~/.tmux/plugins/tpm/bin/install_plugins
}

# Main function
main() {
    install_dependencies
    install_tmux
    install_tpm
    install_rust
    install_cargo_packages
    install_oh_my_zsh
    install_oh_my_zsh_plugins
    setup_config
    install_powerlevel10k
    install_lazyvim
    install_tmux_plugins
    echo "Setup completed successfully."
}

main