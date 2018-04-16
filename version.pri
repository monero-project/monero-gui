RELEASE = "Lithium Luna"
VERSION = 0.12.0

win32 {
    NULL = NUL
} else {
    NULL = /dev/null
}

# get tags
CWD = $$system(pwd)
GIT_VERSION_GUI = $$system(git --git-dir $$CWD/.git describe --always --tags 2> $$NULL)
GIT_VERSION_CORE = $$system(git --git-dir $$CWD/monero/.git describe --always --tags 2> $$NULL)

# fallback version
isEmpty(GIT_VERSION_GUI) GIT_VERSION_GUI = $$VERSION
isEmpty(GIT_VERSION_CORE) GIT_VERSION_CORE = $$VERSION

# make versions available from C++ code 
DEFINES += VERSION_GUI=\\\"$$GIT_VERSION_GUI\\\"
DEFINES += VERSION_CORE=\\\"$$GIT_VERSION_CORE\\\"

# version embedded in the application, without leading "v"
VERSION = $$GIT_VERSION_GUI
VERSION ~= s/v/""

win32 { # numerical - short version. Generate rc file
    VERSION ~= s/-/"."
    VERSION ~= s/g/""
    VERSION ~= s/\.\d+\.[a-f0-9]{6,}//
    QMAKE_TARGET_COMPANY = Monero
    QMAKE_TARGET_DESCRIPTION = Monero $$RELEASE
    QMAKE_TARGET_COPYRIGHT = "2014-2018, The Monero Project"
}

macx { # add version and release to Info.plist
    INFO_PLIST_PATH = $$shell_quote($${TARGET_FULL_PATH}/Contents/Info.plist)
    QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Add :CFBundleShortVersionString string $${VERSION}\" $${INFO_PLIST_PATH};
    QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Set :CFBundleGetInfoString $${RELEASE}\" $${INFO_PLIST_PATH};
}
