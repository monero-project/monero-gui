#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $ROOT_DIR/utils.sh

TARGET=$1

GUI_EXEC=$2

platform=$(get_platform)

if [[ "$platform" == "linux64" ]]; then
    PLAT_DIR="/usr/lib/x86_64-linux-gnu"
elif [[ "$platform" == "linux32" ]]; then
    PLAT_DIR="/usr/lib/i386-linux-gnu"
elif [[ "$platform" == "linuxarmv7" ]]; then
    PLAT_DIR="/usr/lib/arm-linux-gnueabihf"
elif [[ "$platform" == "linuxarmv8" ]]; then
    PLAT_DIR="/usr/lib/aarch64-linux-gnu"
else
    PLAT_DIR="/usr/lib"
fi

if [ -z "$QT_DIR" ]; then
    QT_DIR=$PLAT_DIR/qt5
fi

if [ -z "$QTXML_DIR" ]; then
    QTXML_DIR=$PLAT_DIR
fi

# Copy dependencies
EXCLUDE='libstdc++|libgcc_s.so|libc.so|libpthread'
INCLUDE='libunbound'
cp -rv $QT_DIR/qml $TARGET || exit
cp -rv $QT_DIR/plugins $TARGET || exit
mkdir -p $TARGET/libs || exit
#ldd $TARGET/$GUI_EXEC | grep "=> /" | awk '{print $3}' | grep $INCLUDE | xargs -I '{}' cp -v '{}' $TARGET/libs || exit
#ldd $TARGET/$GUI_EXEC | grep "=> /" | awk '{print $3}' | grep -Ev $EXCLUDE | xargs -I '{}' cp -v '{}' $TARGET/libs || exit
#ldd $TARGET/plugins/platforms/libqxcb.so| grep "=> /" | awk '{print $3}' | grep -Ev $EXCLUDE | xargs -I '{}' cp -v '{}' $TARGET/libs || exit
#cp -v $QTXML_DIR/libQt5XmlPatterns.so.5 $TARGET/libs || exit

# Create start script
cat > $TARGET/start-gui.sh <<EOL
#!/bin/bash
export LD_LIBRARY_PATH=\`pwd\`/libs
export QT_PLUGIN_PATH=\`pwd\`/plugins
export QML2_IMPORT_PATH=\`pwd\`/qml
# make it so that it can be called from anywhere and also through soft links
SCRIPT_DIR="\$(dirname "\$(test -L "\${BASH_SOURCE[0]}" && readlink "\${BASH_SOURCE[0]}" || echo "\${BASH_SOURCE[0]}")")"
"\$SCRIPT_DIR"/$GUI_EXEC
EOL

chmod +x $TARGET/start-gui.sh
