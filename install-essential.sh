#!/bin/bash
export DEBIAN_FRONTEND="noninteractive"
# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
   echo "Please run this script without sudo. The script will ask for sudo permissions when needed."
   exit 1
fi

echo "Installing essential packages..."
sudo apt update
sudo apt install -y build-essential git curl wget zsh tmux terminator unzip python3-nautilus flatpak python3-pip python3-venv ffmpeg gh
wget -qO- https://astral.sh/uv/install.sh | sh
wget https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/.tmux.conf
mkdir -p ./.config/terminator
wget -O ~/.config/terminator/config https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/terminator/config
sudo curl -lo /usr/share/nautilus-python/extensions/open-terminator.py  https://raw.githubusercontent.com/timhughes/nautilus-open-terminator/master/open-terminator.py
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

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
    [ -d "$HOME/デスクトップ" ] && mkdir -p "$HOME/Desktop"    && cp -al "$HOME/デスクトップ/." "$HOME/Desktop/"    && rm -rf "$HOME/デスクトップ"
    [ -d "$HOME/ダウンロード" ] && mkdir -p "$HOME/Downloads"  && cp -al "$HOME/ダウンロード/." "$HOME/Downloads/"  && rm -rf "$HOME/ダウンロード"
    [ -d "$HOME/テンプレート" ] && mkdir -p "$HOME/Templates"  && cp -al "$HOME/テンプレート/." "$HOME/Templates/"  && rm -rf "$HOME/テンプレート"
    [ -d "$HOME/公開" ]       && mkdir -p "$HOME/Public"     && cp -al "$HOME/公開/." "$HOME/Public/"          && rm -rf "$HOME/公開"
    [ -d "$HOME/ドキュメント" ] && mkdir -p "$HOME/Documents" && cp -al "$HOME/ドキュメント/." "$HOME/Documents/" && rm -rf "$HOME/ドキュメント"
    [ -d "$HOME/ミュージック" ] && mkdir -p "$HOME/Music"     && cp -al "$HOME/ミュージック/." "$HOME/Music/"     && rm -rf "$HOME/ミュージック"
    [ -d "$HOME/ピクチャ" ]   && mkdir -p "$HOME/Pictures"   && cp -al "$HOME/ピクチャ/." "$HOME/Pictures/"     && rm -rf "$HOME/ピクチャ"
    [ -d "$HOME/ビデオ" ]     && mkdir -p "$HOME/Videos"     && cp -al "$HOME/ビデオ/." "$HOME/Videos/"         && rm -rf "$HOME/ビデオ"
    
    wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh | bash
    sudo apt install gnome-shell-extensions gnome-software-plugin-flatpak gnome-tweaks gnome-browser-connector -y
fi

flatpak install --assumeyes --noninteractive --or-update flathub it.mijorus.gearlever -y
flatpak install --assumeyes --noninteractive --or-update flathub com.usebottles.bottles -y
flatpak install --assumeyes --noninteractive --or-update https://dl.flathub.org/repo/appstream/io.missioncenter.MissionCenter.flatpakref -y
flatpak override com.usebottles.bottles --user --filesystem=xdg-data/applications

sudo apt install -y nodejs npm
sudo npm -g install n
sudo n stable
sudo apt purge -y nodejs npm
sudo apt autoremove -y

# type -p curl >/dev/null || sudo apt install curl -y
# curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
# && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
# && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
# && sudo apt update \
# && sudo apt install gh -y

git config --global user.name hirobon1690
git config --global user.email 58695125+hirobon1690@users.noreply.github.com
git config --global init.defaultBranch main

sudo gpasswd -a $USER input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
wget https://github.com/xremap/xremap/releases/download/v0.14.1/xremap-linux-x86_64-x11.zip
unzip xremap-linux-x86_64-x11.zip
sudo mv ./xremap /usr/bin/
rm ./xremap-linux-x86_64-x11.zip
wget -O ~/.xremap.yml https://raw.githubusercontent.com/hirobon1690/dotfiles/refs/heads/main/.xremap.yml 
mkdir -p ~/.config/systemd/user && cat <<'EOF' > ~/.config/systemd/user/xremap.service
[Unit]
Description=xremap

[Service]
KillMode=process
ExecStart=/usr/bin/xremap --watch %h/.xremap.yml
Type=simple
Restart=always
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

systemctl --user enable xremap.service
systemctl --user start xremap.service

. ./install-omz.sh