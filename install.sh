#!/usr/bin/zsh

set -e

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
BAT_REPO="https://github.com/sharkdp/bat/releases/latest/download/bat_0.18.3_amd64.deb"

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

install_bat() {
    echo "Installing bat..."
    wget -O bat.deb "${BAT_REPO}"
    sudo dpkg -i bat.deb
    rm bat.deb
}


install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    export KEEP_ZSHRC="yes"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    unset KEEP_ZSHRC
    #sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
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
    git clone --depth=1 "${POWERLEVEL10K_REPO}" "${OH_MY_ZSH_CUSTOM}/themes/powerlevel10k"
    # Add Powerlevel10k configuration to .zshrc
    cat <<EOF >> "$HOME/.zshrc"
# To customize Powerlevel10k, edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    # Copy the .p10k.zsh file from the repository
    cp "${CONFIG_DIR}/.p10k.zsh" "$HOME/.p10k.zsh"
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

# Main function
main() {
    install_dependencies
    install_tmux
    install_bat
    install_oh_my_zsh
    install_oh_my_zsh_plugins
    setup_config
    install_powerlevel10k
    install_lazyvim
    echo "Setup completed successfully."
}

main