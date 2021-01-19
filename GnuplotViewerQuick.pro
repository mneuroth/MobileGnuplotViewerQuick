QT += qml quick quickcontrols2 svg printsupport

android {
    QT += purchasing
}

greaterThan(QT_MAJOR_VERSION, 5): QT += core5compat

#QT += quickdialogs

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        androidtasks.cpp \
        applicationdata.cpp \
        applicationui.cpp \
        gnuplotinvoker.cpp \
        gnuplotsyntaxhighlighter.cpp \
        main.cpp \
        shareutils.cpp \
        storageaccess.cpp

RESOURCES += qml.qrc

TRANSLATIONS += \
    GnuplotViewerQuick_de_DE.ts \
    GnuplotViewerQuick_nl_NL.ts
    //es_ES
    //pt_PT
    //fr_FR
    //it_IT
    //ru_RU

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    androidtasks.h \
    applicationdata.h \
    applicationui.hpp \
    gnuplotinvoker.h \
    gnuplotsyntaxhighlighter.h \
    shareutils.hpp \
    storageaccess.h

wasm {  # wasm_32 ?
    DEFINES += _USE_BUILTIN_GNUPLOT

    include(gnuplot/gnuplot.pri)
}

ios {
    LIBS += -L/usr/local/lib -liconv

    DEFINES += _USE_BUILTIN_GNUPLOT

    include(gnuplot/gnuplot.pri)
}

android {
    SOURCES += android/androidshareutils.cpp

    HEADERS += android/androidshareutils.hpp

    # see: http://qt-project.org/forums/viewthread/16781
    # see: http://community.kde.org/Necessitas/Assets
    # see: https://groups.google.com/forum/#!msg/android-qt/zmtqbUz7KmI/3jLoaK84fd4J

    QT += androidextras

    equals(ANDROID_TARGET_ARCH, arm64-v8a) {
        ARCH_PATH = arm64
    }
    equals(ANDROID_TARGET_ARCH, armeabi-v7a) {
        ARCH_PATH = arm
    }
    equals(ANDROID_TARGET_ARCH, armeabi) {
        ARCH_PATH = arm
    }
    equals(ANDROID_TARGET_ARCH, x86)  {
        ARCH_PATH = i386
    }
    equals(ANDROID_TARGET_ARCH, x86_64)  {
        ARCH_PATH = x86_64
    }
    equals(ANDROID_TARGET_ARCH, mips)  {
        ARCH_PATH = mips
    }
    equals(ANDROID_TARGET_ARCH, mips64)  {
        ARCH_PATH = mips64
    }

deployment1.files=files/$$ARCH_PATH/gnuplot_android
deployment1.path=/assets/files/$$ARCH_PATH

deployment2.files=files/arm/gnuplot.gih
deployment2.path=/assets/files

deployment3.files=files/arm/gnuplot_copyright
deployment3.path=/assets/files

#deployment4.files=files/empty.svg
#deployment4.path=/assets/files

deployment5.files=files/faq.txt
deployment5.path=/assets/files

deployment6.files=files/gnuplotviewer_license.txt
deployment6.path=/assets/files

deployment7.files=files/$$ARCH_PATH/gnuplot_android_beta
deployment7.path=/assets/files/$$ARCH_PATH

script1.files=files/scripts/simple.gpt
script1.path=/assets/files/scripts

script2.files=files/scripts/fitdata.gpt
script2.path=/assets/files/scripts

script3.files=files/scripts/splot.gpt
script3.path=/assets/files/scripts

script4.files=files/scripts/multiplot.gpt
script4.path=/assets/files/scripts

script5.files=files/scripts/butterfly.gpt
script5.path=/assets/files/scripts

script6.files=files/scripts/default.gpt
script6.path=/assets/files/scripts

data2.files=files/scripts/data.dat
data2.path=/assets/files/scripts


INSTALLS += deployment1
INSTALLS += deployment2
INSTALLS += deployment3
#INSTALLS += deployment4
INSTALLS += deployment5
INSTALLS += deployment6
INSTALLS += deployment7
INSTALLS += script1
INSTALLS += script2
INSTALLS += script3
INSTALLS += script4
INSTALLS += script5
INSTALLS += script6
INSTALLS += data2
}

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/res/xml/filepaths.xml \
    android/src/de/mneuroth/activity/sharex/QShareActivity.java \
    android/src/de/mneuroth/utils/QSharePathResolver.java \
    android/src/de/mneuroth/utils/QShareUtils.java \
    android/src/de/mneuroth/utils/QStorageAccess.java

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

ios {
    OBJECTIVE_SOURCES += ios/src/iosshareutils.mm \
    ios/src/docviewcontroller.mm

    HEADERS += ios/iosshareutils.hpp \
               ios/docviewcontroller.hpp

    QMAKE_INFO_PLIST = ios/Info.plist

    QMAKE_IOS_DEPLOYMENT_TARGET = 9.0

    disable_warning.name = GCC_WARN_64_TO_32_BIT_CONVERSION
    disable_warning.value = NO
    QMAKE_MAC_XCODE_SETTINGS += disable_warning

    # see https://bugreports.qt.io/browse/QTCREATORBUG-16968
    # ios_signature.pri not part of project repo because of private signature details
    # contains:
    # QMAKE_XCODE_CODE_SIGN_IDENTITY = "iPhone Developer"
    # MY_DEVELOPMENT_TEAM.name = DEVELOPMENT_TEAM
    # MY_DEVELOPMENT_TEAM.value = your team Id from Apple Developer Account
    # QMAKE_MAC_XCODE_SETTINGS += MY_DEVELOPMENT_TEAM

#    include(ios_signature.pri)

    MY_BUNDLE_ID.name = PRODUCT_BUNDLE_IDENTIFIER
    MY_BUNDLE_ID.value = de.mneuroth.mobilegnuplotviewerquick
    QMAKE_MAC_XCODE_SETTINGS += MY_BUNDLE_ID

    # Note for devices: 1=iPhone, 2=iPad, 1,2=Universal.
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
}

ANDROID_ABIS = armeabi-v7a arm64-v8a x86 x86_64
