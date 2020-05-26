QT += quick quickcontrols2 svg

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
        gnuplotinvoker.cpp \
        gnuplotsyntaxhighlighter.cpp \
        main.cpp

RESOURCES += qml.qrc

TRANSLATIONS += \
    GnuplotViewerQuick_de_DE.ts

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
    gnuplotinvoker.h \
    gnuplotsyntaxhighlighter.h

android {
#SOURCES += android/androidshareutils.cpp

#HEADERS += android/androidshareutils.hpp

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
        ARCH_PATH = x86
    }
    equals(ANDROID_TARGET_ARCH, x86_64)  {
        ARCH_PATH = x64
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

deployment4.files=files/empty.svg
deployment4.path=/assets/files

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

data2.files=files/scripts/data.dat
data2.path=/assets/files/scripts


INSTALLS += deployment1
INSTALLS += deployment2
INSTALLS += deployment3
INSTALLS += deployment4
INSTALLS += deployment5
INSTALLS += deployment6
INSTALLS += deployment7
INSTALLS += script1
INSTALLS += script2
INSTALLS += script3
INSTALLS += script4
INSTALLS += script5
INSTALLS += data2
}

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
