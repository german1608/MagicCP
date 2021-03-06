#!/usr/bin/env bash
# Setup the development environment
mkdir -p ./bin ./logs

# Install third party dependencies
echo "ℹ️ Installing apt dependencies..."
sudo apt-get install libcurl4-openssl-dev -y

# Install cf-tool
echo "ℹ️ Checking if cf-tool is installed..."

if [ ! -f ./bin/cf ]; then
    echo "❌ cf-tool is not installed. Installing..."
    CF_TOOL_VERSION='v1.0.0'
    CF_ZIP=$(mktemp --suffix=.zip)
    CF_DIR=$(mktemp -d)

    CF_URL=https://github.com/xalanq/cf-tool/releases/download/$CF_TOOL_VERSION/cf_"$CF_TOOL_VERSION"_linux_64.zip
    echo "Downloading from $CF_URL"
    wget $CF_URL -O $CF_ZIP
    unzip -o $CF_ZIP -d $CF_DIR
    mv $CF_DIR/cf_"$CF_TOOL_VERSION"_linux_64/cf ./bin/cf
    [ -f ./bin/cf ] && echo "✅ cf-tool was succesfully installed"
else
    echo "✅ cf-tool is installed"
fi

echo "ℹ️ Generating config.cfg file..."
cat << EOF > config.cfg
cf-tool-path = "$PWD/bin"
project-root = "$PWD"
cf-parse-dir = "$PWD/cf/contest"
log-root = "$PWD/logs"
EOF
echo "✅ config.cfg file generated"


echo "ℹ️ Checking if chromedriver is installed..."
if ! command -v chromedriver &> /dev/null
then
    echo "❌ chromedriver is not installed. Installing..."
    mkdir -p $HOME/bin
    # see the following for URL construction for chromedriver download
    # https://chromedriver.chromium.org/downloads/version-selection
    CHROME_VERSION=$(google-chrome --version | cut -d' ' -f 3)
    echo "Installed google-chrome version: $CHROME_VERSION"
    CHROME_VERSION_WITHOUT_BUILD_NUMBER=$(echo $CHROME_VERSION | cut -d'.' -f1,2,3)
    LATEST_CHROME_VERSION_AVAILABLE=$(wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION_WITHOUT_BUILD_NUMBER -O - 2> /dev/null)

    echo "Latest chromedriver version available: $LATEST_CHROME_VERSION_AVAILABLE"
    CHROMEDRIVER_URL=https://chromedriver.storage.googleapis.com/$LATEST_CHROME_VERSION_AVAILABLE/chromedriver_linux64.zip

    CHROMEDRIVER_ZIP=$(mktemp --suffix=.zip)
    wget $CHROMEDRIVER_URL -O $CHROMEDRIVER_ZIP
    unzip -o $CHROMEDRIVER_ZIP -d $HOME/bin
    [ -f $HOME/bin/chromedriver ] && echo "✅ chromedriver was succesfully installed"
else
    echo "✅ chromedriver is installed"
fi


echo "ℹ️ Checking if stylish-haskell is installed..."
if ! command -v stylish-haskell &> /dev/null
then
    echo "❌ stylish-haskell is not installed. Installing..."
    mkdir -p $HOME/bin
    SH_VERSION=v0.12.2.0
    SH_URL=https://github.com/jaspervdj/stylish-haskell/releases/download/$SH_VERSION/stylish-haskell-$SH_VERSION-linux-x86_64.tar.gz

    SH_TARBALL=$(mktemp --suffix=.tar.gz)
    SH_DIR=$(mktemp -d)
    wget $SH_URL -O $SH_TARBALL
    tar -xvf $SH_TARBALL -C $SH_DIR
    ls $SH_DIR
    mv $SH_DIR/stylish-haskell-$SH_VERSION-linux-x86_64/stylish-haskell $HOME/bin/
    [ -f $HOME/bin/stylish-haskell ] && echo "✅ stylish-haskell was succesfully installed"
else
    echo "✅ stylish-haskell is installed"
fi

echo "ℹ️ Configuring authentication details for cf"
echo "   Please, choose option number 0 and set your codeforces credentials"
cf config

echo "ℹ️ Overwriting ~/.cf/config"
mkdir -p $HOME/.cf/
cat << EOF > $HOME/.cf/config
{
  "template": [
    {
      "alias": "hs",
      "lang": "12",
      "path": "/home/german/.cf/templates/template.hs",
      "suffix": [
        "hs"
      ],
      "before_script": "ghc $%full%$",
      "script": "./$%file%$",
      "after_script": ""
    }
  ],
  "default": 0,
  "gen_after_parse": false,
  "host": "https://codeforces.com",
  "proxy": "",
  "folder_name": {
    "acmsguru": "acmsguru",
    "contest": "contest",
    "group": "group",
    "gym": "gym",
    "root": "cf"
  }
}
EOF
echo "✅ ~/.cf/config properly set"

echo "ℹ️ Setting haskell template for cf-tool"
mkdir -p ~/.cf/templates/
touch ~/.cf/templates/template.hs
echo "✅ Template configured"
