#!/bin/bash
export DEBIAN_FRONTEND="noninteractive"
# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
   echo "Please run this script without sudo. The script will ask for sudo permissions when needed."
   exit 1
fi

echo "Installing essential packages..."
sudo apt update
sudo apt install -y build-essential git curl wget zsh tmux terminator unzip python3-nautilus
wget https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/.tmux.conf
mkdir -p ./.config/terminator
wget https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/terminator/config -O ./.config/terminator/config
sudo curl -lo /usr/share/nautilus-python/extensions/open-terminator.py  https://raw.githubusercontent.com/timhughes/nautilus-open-terminator/master/open-terminator.py

# Check if running in WSL
if grep -qi microsoft /proc/version; then
    echo "WSL environment detected. Configuring WSL..."
    echo -e "[interop]\nappendWindowsPath = false" | sudo tee -a /etc/wsl.conf
    echo "WSL configuration added. Please restart WSL to apply changes."
else
    echo "Regular Linux environment detected. Installing desktop applications..."
    
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update
    sudo apt install -y code

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrom-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/googlechrom-keyring.gpg
    sudo apt update
    sudo apt install -y google-chrome-stable

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    mkdir JetBrainsMono
    unzip ./JetBrainsMono.zip -d ./JetBrainsMono
    sudo cp ./JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf /usr/share/fonts/
    sudo cp ./JetBrainsMono/JetBrainsMonoNerdFont-Bold.ttf /usr/share/fonts/
    rm -rf ./JetBrainsMono
    rm ./JetBrainsMono.zip
    
    LANG=C xdg-user-dirs-update --force
    cp -al ~/デスクトップ/* ~/Desktop/
    cp -al ~/ダウンロード/* ~/Downloads/
    cp -al ~/テンプレート/* ~/Templates/
    cp -al ~/公開/* ~/Public/
    cp -al ~/ドキュメント/* ~/Documents/
    cp -al ~/音楽/* ~/Music/
    cp -al ~/画像/* ~/Pictures/
    cp -al ~/ビデオ/* ~/Videos/
    rm -rf デスクトップ ダウンロード テンプレート 公開 ドキュメント 音楽 画像 ビデオ
    wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh | bash
fi

sudo add-apt-repository ppa:appimagelauncher-team/stable -y
sudo apt install -y appimagelauncher

sudo apt install -y nodejs npm
sudo npm -g install n
sudo n stable
sudo apt purge -y nodejs npm
sudo apt autoremove -y

type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

git config --global user.name hirobon1690
git config --global user.email 58695125+hirobon1690@users.noreply.github.com
git config --global init.defaultBranch main

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
