#!/data/data/com.icst.blockidle/files/usr/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

cecho() {
  local color="$1"
  shift
  echo -e "${color}$*${RESET}"
}

red()     { cecho "$RED" "$@"; }
green()   { cecho "$GREEN" "$@"; }
yellow()  { cecho "$YELLOW" "$@"; }
blue()    { cecho "$BLUE" "$@"; }
magenta() { cecho "$MAGENTA" "$@"; }
cyan()    { cecho "$CYAN" "$@"; }

print_row() {
  printf "| %-15s | %-20s |\n" "$1" "$2"
}

BUILD_TOOLS_APT_REPO_ZIP_FILE_URL="https://github.com/Innovative-CST/blockidle-pkg-buildtools-mirror/releases/download/v1.0.1/blockidle-pkg-buildtools-mirror.zip"
BLOCKIDLE_DIR=$HOME/.blockidle
TEMP_BUILD_TOOLS_APT_REPO_ZIP=$BLOCKIDLE_DIR/build-tools-apt.zip
APT_REPO_DESTINATION=$BLOCKIDLE_DIR/blockidle-pkg-buildtools-mirror
MIRROR_SOURCE_DIR=$PREFIX/etc/apt/sources.list.d
BUILD_TOOLS_MIRROR_FILE=$MIRROR_SOURCE_DIR/build-tools.list

if [ -e $BLOCKIDLE_DIR ]; then
  if [ ! -d $BLOCKIDLE_DIR ]; then
    rm -rf $BLOCKIDLE_DIR
    mkdir $BLOCKIDLE_DIR
  fi
else
  mkdir $BLOCKIDLE_DIR
fi

if [ -d $APT_REPO_DESTINATION ]; then
    yellow "Build tools already exists"
    read -p $'\e[1;35mDo you want to re-download it, incase if you think it is corrupted or outdated? (y/N): \e[0m' confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        blue "Re-downloading build tools file..."
        curl -Lo $TEMP_BUILD_TOOLS_APT_REPO_ZIP $BUILD_TOOLS_APT_REPO_ZIP_FILE_URL
    else
        yellow "Skipping download."
    fi
else
    blue "Downloading build tools file in temp file..."
    curl -Lo $TEMP_BUILD_TOOLS_APT_REPO_ZIP $BUILD_TOOLS_APT_REPO_ZIP_FILE_URL
fi

if [ ! -f $TEMP_BUILD_TOOLS_APT_REPO_ZIP ] && [ ! -d $APT_REPO_DESTINATION ]; then
    red "Download failed or file is empty!"
    exit 1
fi

if [ -e $TEMP_BUILD_TOOLS_APT_REPO_ZIP ]; then
  blue "Unzipping build-tools temporary file"
  unzip -oq $TEMP_BUILD_TOOLS_APT_REPO_ZIP -d $APT_REPO_DESTINATION
  green "Finished unzipping"
fi

if [ -e $TEMP_BUILD_TOOLS_APT_REPO_ZIP ]; then
  yellow "Cleaning up temporaring build-tools file..."
  rm $TEMP_BUILD_TOOLS_APT_REPO_ZIP
fi

mkdir -p $MIRROR_SOURCE_DIR
cat > $BUILD_TOOLS_MIRROR_FILE <<EOF
deb file://$APT_REPO_DESTINATION/ stable main

EOF

apt update

# Install OpenJDK
blue "Installing OpenJDK..."
pkg install -y openjdk-17 > /dev/null 2>&1

# Install Gradle
blue "Installing Gradle..."
pkg install -y gradle > /dev/null 2>&1

read -p $'\e[1;35mDo you want to uninstall build-tools apt repository installed in your system (700MB+)? This repository is only used to install build packages; you can reinstall it whenever needed (y/N): \e[0m' confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    yellow "Cleaning up APT repository"
    rm -rf $TEMP_BUILD_TOOLS_APT_REPO_ZIP $BUILD_TOOLS_APT_REPO_ZIP_FILE_URL
    rm -f $BUILD_TOOLS_MIRROR_FILE
  else
    yellow "APT repository will be kept in case you install packages from it."
  fi

jdk_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
gradle_version=$(gradle --version 2>/dev/null | awk '/^Gradle / {print $2; exit}')
# Print table header
echo
echo "Installed Packages and Versions:"
echo "+-----------------+----------------------+"
print_row "Package" "Version"
echo "+-----------------+----------------------+"
print_row "OpenJDK" "$jdk_version"
print_row "Gradle" "$gradle_version"
echo "+-----------------+----------------------+"
