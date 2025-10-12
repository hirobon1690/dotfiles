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
wget https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/terminator/config ./.config/terminator/config
sudo curl -lo /usr/share/nautilus-python/extensions/open-terminator.py  https://raw.githubusercontent.com/timhughes/nautilus-open-terminator/master/open-terminator.py

# Check if running in WSL
if grep -qi microsoft /proc/version; then
    echo "WSL environment detected. Configuring WSL..."
    echo -e "[interop]\nappendWindowsPath = false" | sudo tee -a /etc/wsl.conf
    echo "WSL configuration added. Please restart WSL to apply changes."
else
     echo "Regular Linux environment detected. Installing desktop applications..."
     set -e
     sudo install -m 0755 -d /etc/apt/keyrings
     wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null
     echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
       | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
 
    sudo apt-get -yq update
    sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a UCF_FORCE_CONFNEW=1 \
    apt-get -yq install code

    
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

    wget https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
    mkdir Inter
    unzip ./Inter-4.1.zip -d ./Inter
    sudo cp ./Inter/extras/ttf/Inter-Bold.ttf /usr/share/fonts/
    sudo cp ./Inter/extras/ttf/Inter-Regular.ttf /usr/share/fonts/
    sudo cp ./Inter/extras/ttf/Inter-BoldItalic.ttf /usr/share/fonts/
    sudo cp ./Inter/extras/ttf/Inter-Italic.ttf /usr/share/fonts/
    rm -rf ./Inter
    rm ./Inter-4.1.zip
    
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

echo setopt GLOB_SUBST >> ~/.zshenv && source ~/.zshenv

git config --global user.name hirobon1690
git config --global user.email 58695125+hirobon1690@users.noreply.github.com
git config --global init.defaultBranch main

sudo gpasswd -a $USER input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
wget https://github.com/xremap/xremap/releases/download/v0.14.1/xremap-linux-x86_64-x11.zip
unzip xremap-linux-x86_64-x11.zip
sudo mv ./xremap /usr/bin/
rm ./xremap-linux-x86_64-x11.zip
wget https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/xremap.yml ~/.xremap.yml
mkdir -p ~/.config/systemd/user && cat <<'EOF' > ~/.config/systemd/user/xremap.service
[Unit]
Description=xremap

[Service]
KillMode=process
ExecStart=/usr/bin/xremap --watch /home/hirobon/xremap.yml
Type=simple
Restart=always
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

systemctl --user enable xremap.service
systemctl --user start xremap.service

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
