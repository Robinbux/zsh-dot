#!/usr/bin/zsh

# Define variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
LAZYVIM_REPO="https://github.com/LazyVim/starter"
OH_MY_ZSH_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
OH_MY_ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
ZSH_AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
TPM_REPO="https://github.com/tmux-plugins/tpm"

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

install_atuin() {
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
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

    # Clean content of current .zshrc
    echo "" > "$HOME/.zshrc"

    # Source all .zsh files in the repository
    cat <<EOF >> "$HOME/.zshrc"
# Source all .zsh files in the repository
ZSH_CONFIG_DIR="$HOME/.config/zsh"

for file in ${SCRIPT_DIR}/*.zsh; do
    source \$file
done
EOF
}

install_oh_my_posh() {
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
}

main() {
    install_dependencies
    install_tmux
    install_tpm
    install_rust
    install_cargo_packages
    install_atuin
    install_oh_my_zsh
    install_oh_my_zsh_plugins
    install_oh_my_posh
    setup_config
    install_lazyvim
    install_tmux_plugins
    echo "Setup completed successfully."
}

main
