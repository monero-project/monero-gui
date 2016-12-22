#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $ROOT_DIR/utils.sh

TARGET=$1

GUI_EXEC=$2

platform=$(get_platform)

# Copy dependencies
EXCLUDE='libstdc++|libgcc_s.so|libc.so|libpthread'
cp -rv /usr/lib/x86_64-linux-gnu/qt5/qml $TARGET
cp -rv /usr/lib/x86_64-linux-gnu/qt5/plugins $TARGET
mkdir -p $TARGET/libs
ldd $TARGET/$GUI_EXEC | grep "=> /" | awk '{print $3}' | grep -Ev $EXCLUDE | xargs -I '{}' cp -v '{}' $TARGET/libs
ldd $TARGET/plugins/platforms/libqxcb.so| grep "=> /" | awk '{print $3}' | grep -Ev $EXCLUDE | xargs -I '{}' cp -v '{}' $TARGET/libs
cp -v /usr/lib/x86_64-linux-gnu/libQt5XmlPatterns.so.5 $TARGET/libs

# Create start script
cat > $TARGET/start-gui.sh <<EOL
#!/bin/bash
# export LD_LIBRARY_PATH=\`pwd\`/libs
export QT_PLUGIN_PATH=\`pwd\`/plugins
export QML2_IMPORT_PATH=\`pwd\`/qml
./$GUI_EXEC
EOL
