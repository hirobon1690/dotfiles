#!/bin/bash

echo "Setting zsh as default shell..."
sudo chsh -s $(which zsh) $USER

# Oh My Zshを非対話的にインストール
echo "Installing Oh My Zsh..."
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# プラグインをインストール
echo "Installing zsh plugins..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# .zshrcが存在することを確認してから設定を変更
if [ -f "$HOME/.zshrc" ]; then
    echo "Configuring zsh plugins and theme..."
    # プラグインを追加（既に存在しない場合のみ）
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i '/^plugins=(/ s/)/ zsh-autosuggestions)/' "$HOME/.zshrc"
    fi
    if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
        sed -i '/^plugins=(/ s/)/ zsh-syntax-highlighting)/' "$HOME/.zshrc"
    fi
    
    # オートサジェスト設定を追加（重複回避）
    if ! grep -q "ZSH_AUTOSUGGEST_STRATEGY" "$HOME/.zshrc"; then
        echo "ZSH_AUTOSUGGEST_STRATEGY=(completion history)" >> "$HOME/.zshrc"
    fi
    
    # テーマを変更
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
    
    echo "Configuration completed! Please restart your terminal or run 'exec zsh' to apply changes."
else
    echo "Warning: .zshrc file not found. Oh My Zsh installation may have failed."
fi