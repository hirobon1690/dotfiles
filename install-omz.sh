#!/bin/bash

echo "Setting zsh as default shell..."
sudo chsh -s $(which zsh) $USER

# Oh My Zshを非対話的にインストール
echo "Installing Oh My Zsh and extensions..."
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# プラグインをインストール
echo "Installing zsh plugins..."
if ! command -v fzf >/dev/null 2>&1; then
    sudo apt install -y fzf
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
fi

# .zshrcが存在することを確認してから設定を変更
if [ -f "$HOME/.zshrc" ]; then
    echo "Configuring zsh plugins and theme..."
    # 重複を除き、fzf-tabを入力候補・ハイライトより前に読み込む
    sed -i -E '/^plugins=\(/ {
        s/\<(fzf-tab|zsh-autosuggestions|zsh-syntax-highlighting)\>//g
        s/[[:blank:]]*\)/ fzf-tab zsh-autosuggestions zsh-syntax-highlighting)/
    }' "$HOME/.zshrc"
    
    # オートサジェスト設定を追加（重複回避）
    if ! grep -q "ZSH_AUTOSUGGEST_STRATEGY" "$HOME/.zshrc"; then
        echo "ZSH_AUTOSUGGEST_STRATEGY=(completion history)" >> "$HOME/.zshrc"
    fi
    
    # テーマを変更
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' "$HOME/.zshrc"

    # 管理ブロックを置き換え、再実行でも設定を重複させない
    sed -i '/^# >>> dotfiles fzf-tab >>>$/,/^# <<< dotfiles fzf-tab <<<$/d' "$HOME/.zshrc"
    cat >> "$HOME/.zshrc" <<'EOF'
# >>> dotfiles fzf-tab >>>
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':completion:*:*:*:*:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' switch-group left right
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'ls -A --color=always -- "$realpath"'
zstyle ':completion:*:git-checkout:*' sort false

# Read SSH config instead of stopping at system hosts.
# Hosts found only in /etc/hosts or known_hosts are omitted.
zstyle ':completion:*:(ssh|scp|sftp):*' hosts

# Requires tmux 3.2 or newer.
if [[ -n "$TMUX" ]]; then
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi
# <<< dotfiles fzf-tab <<<
EOF
    
    echo "Configuration completed! Please restart your terminal or run 'exec zsh' to apply changes."
else
    echo "Warning: .zshrc file not found. Oh My Zsh installation may have failed."
fi
