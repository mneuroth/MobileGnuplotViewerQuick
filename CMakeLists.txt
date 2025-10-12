cmake_minimum_required(VERSION 3.16)

project(GnuplotViewerQuick VERSION 0.1 LANGUAGES C CXX)

set(USE_ANDROID_TOOLS ON)
#set(QT_ANDROID_BUILD_ALL_ABIS ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_VERBOSE_MAKEFILE ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg Core5Compat Widgets PrintSupport)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(GnuplotViewerQuickQt6
    main.cpp
    purchasing/inapp/inappproduct.cpp purchasing/inapp/inappproduct.h
    purchasing/inapp/inapppurchasebackend.cpp purchasing/inapp/inapppurchasebackend.h
    purchasing/inapp/inappstore.cpp purchasing/inapp/inappstore.h
    purchasing/inapp/inapptransaction.cpp purchasing/inapp/inapptransaction.h
    purchasing/qmltypes/inappproductqmltype.cpp purchasing/qmltypes/inappproductqmltype.h
    purchasing/qmltypes/inappstoreqmltype.cpp purchasing/qmltypes/inappstoreqmltype.h
)

target_include_directories(GnuplotViewerQuickQt6 PRIVATE
    gnuplot
    gnuplot/src
    gnuplot/term
    purchasing/inapp
    purchasing/qmltypes
)

#set_target_properties(GnuplotViewerQuickQt6 PROPERTIES
#    QT_ANDROID_MULTI_ABIS "arm64-v8a;x86_64"
##    QT_ANDROID_MULTI_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64"
#)

qt_add_qml_module(GnuplotViewerQuickQt6
    URI GnuplotViewerQuick
    VERSION 1.0
    QML_FILES
        main.qml
        QML_FILES AboutDialog.qml
		QML_FILES AboutDialogForm.ui.qml
                QML_FILES MobileFileDialog.qml
		QML_FILES MobileFileDialogForm.ui.qml
		QML_FILES SettingsDialog.qml
		QML_FILES SettingsDialogForm.ui.qml
		QML_FILES SupportDialogForm.ui.qml
		QML_FILES SupportDialog.qml
		QML_FILES PageGraphics.qml
		QML_FILES PageGraphicsForm.ui.qml
		QML_FILES PageHelp.qml
		QML_FILES PageHelpForm.ui.qml
		QML_FILES PageHome.qml
		QML_FILES PageHomeForm.ui.qml
		QML_FILES PageOutput.qml
		QML_FILES PageOutputForm.ui.qml
		QML_FILES ReplaceDialog.qml
		QML_FILES ReplaceDialogForm.ui.qml
		QML_FILES FindDialog.qml
		QML_FILES FindDialogForm.ui.qml
                QML_FILES SaveAsDialog.qml
                QML_FILES SaveAsDialogForm.ui.qml
    SOURCES
		applicationdata.h
		applicationdata.cpp
		qmlfunctions.h
		qmlfunctions.cpp
		gnuplotinvoker.h
		gnuplotinvoker.cpp
		gnuplotsyntaxhighlighter.h
		gnuplotsyntaxhighlighter.cpp
		androidtasks.h
		androidtasks.cpp
		storageaccess.h
		storageaccess.cpp
                applicationui.hpp
		applicationui.cpp
                shareutils.hpp
		shareutils.cpp

    RESOURCES
                pico.png
                files/empty.svg
                files/line-chart.svg
                files/information.svg
                files/log-format.svg
                files/document.svg
                images/gnuplotviewer_flat_512x512.png
                files/floppy-disk.svg
                files/open-folder-with-document.svg
                files/menu.svg
                files/menu_bars.svg
                files/back.svg
                files/share.svg
                files/search.svg
                files/replace.svg
                files/settings.svg
                files/close.svg
                files/coin.svg
                files/left-arrow.svg
                files/right-arrow.svg
                files/back-arrow.svg
                files/redo-arrow.svg
                files/edit.svg
                files/file96.svg
                files/new104.svg
                files/play-button-arrowhead.svg
                files/high-five.svg
                RESOURCES android/AndroidManifest.xml android/build.gradle android/res/values/libs.xml android/res/xml/qtprovider_paths.xml android/gradle/wrapper/gradle-wrapper.jar android/gradle/wrapper/gradle-wrapper.properties android/gradle.properties android/gradlew android/gradlew.bat
        #RESOURCES android/AndroidManifest.xml android/build.gradle android/res/values/libs.xml android/res/xml/qtprovider_paths.xml android/gradle/wrapper/gradle-wrapper.jar android/gradle/wrapper/gradle-wrapper.properties android/gradle.properties android/gradlew android/gradlew.bat
)

if (NOT EMSCRIPTEN)
    qt6_add_resources(GnuplotViewerQuickQt6 "resources"
        PREFIX "/"
        FILES
        files/scripts/default.gpt
        files/scripts/butterfly.gpt
        files/scripts/fitdata.gpt
        files/scripts/multiplot.gpt
        files/scripts/simple.gpt
        files/scripts/splot.gpt
        files/scripts/test.gpt
        files/scripts/data.dat
        GnuplotViewerQuick_de_DE.qm
        GnuplotViewerQuick_nl_NL.qm
        GnuplotViewerQuick_es_ES.qm
        GnuplotViewerQuick_fr_FR.qm
    )
endif()

qt_add_resources(GnuplotViewerQuickQt6 "app_images"
    PREFIX "/"
    FILES
        pico.png
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(GnuplotViewerQuickQt6 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.QtQuickMemoApp
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

#set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android")

if(ANDROID)
    #set_property(TARGET QtQuickMemoApp APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #    ${CMAKE_CURRENT_SOURCE_DIR}/purchasing/android
    #)

    target_sources(GnuplotViewerQuickQt6 PRIVATE
        purchasing/android/androidinappproduct.cpp purchasing/android/androidinappproduct.h
        purchasing/android/androidinapppurchasebackend.cpp purchasing/android/androidinapppurchasebackend.h
        purchasing/android/androidinapptransaction.cpp purchasing/android/androidinapptransaction.h
        purchasing/android/androidjni.cpp

gnuplot/config.h
gnuplot/src/alloc.h
gnuplot/src/axis.h
gnuplot/src/bitmap.h
gnuplot/src/boundary.h
gnuplot/src/breaders.h
gnuplot/src/color.h
gnuplot/src/command.h
gnuplot/src/contour.h
gnuplot/src/datablock.h
gnuplot/src/datafile.h
gnuplot/src/dynarray.h
gnuplot/src/encoding.h
gnuplot/src/eval.h
gnuplot/src/external.h
gnuplot/src/fit.h
gnuplot/src/gadgets.h
gnuplot/src/getcolor.h
gnuplot/src/gp_hist.h
gnuplot/src/gp_time.h
gnuplot/src/gp_types.h
gnuplot/src/gpexecute.h
gnuplot/src/graph3d.h
gnuplot/src/graphics.h
gnuplot/src/hidden3d.h
gnuplot/src/internal.h
gnuplot/src/interpol.h
gnuplot/src/jitter.h
gnuplot/src/libcerf.h
gnuplot/src/matrix.h
gnuplot/src/misc.h
gnuplot/src/mouse.h
gnuplot/src/mousecmn.h
gnuplot/src/multiplot.h
gnuplot/src/national.h
gnuplot/src/parse.h
gnuplot/src/plot.h
gnuplot/src/plot2d.h
gnuplot/src/plot3d.h
gnuplot/src/pm3d.h
gnuplot/src/readline.h
gnuplot/src/save.h
gnuplot/src/scanner.h
gnuplot/src/setshow.h
gnuplot/src/specfun.h
gnuplot/src/standard.h
gnuplot/src/stats.h
gnuplot/src/stdfn.h
gnuplot/src/syscfg.h
gnuplot/src/tables.h
gnuplot/src/tabulate.h
gnuplot/src/term.h
gnuplot/src/term_api.h
gnuplot/src/util.h
gnuplot/src/util3d.h
gnuplot/src/variable.h
gnuplot/src/voxelgrid.h
gnuplot/src/vplot.h
gnuplot/src/version.h
gnuplot/src/alloc.c
gnuplot/src/axis.c
gnuplot/src/bitmap.c
gnuplot/src/boundary.c
gnuplot/src/breaders.c
gnuplot/src/color.c
gnuplot/src/command.c
gnuplot/src/contour.c
gnuplot/src/datablock.c
gnuplot/src/datafile.c
gnuplot/src/dynarray.c
gnuplot/src/encoding.c
gnuplot/src/eval.c
gnuplot/src/external.c
gnuplot/src/fit.c
gnuplot/src/gadgets.c
gnuplot/src/getcolor.c
gnuplot/src/gpexecute.c
gnuplot/src/graph3d.c
gnuplot/src/graphics.c
gnuplot/src/help.c
gnuplot/src/hidden3d.c
gnuplot/src/history.c
gnuplot/src/internal.c
gnuplot/src/interpol.c
gnuplot/src/jitter.c
gnuplot/src/libcerf.c
gnuplot/src/matrix.c
gnuplot/src/misc.c
gnuplot/src/mouse.c
gnuplot/src/multiplot.c
gnuplot/src/parse.c
gnuplot/src/plot.c
gnuplot/src/plot2d.c
gnuplot/src/plot3d.c
gnuplot/src/pm3d.c
gnuplot/src/readline.c
gnuplot/src/save.c
gnuplot/src/scanner.c
gnuplot/src/set.c
gnuplot/src/show.c
gnuplot/src/specfun.c
gnuplot/src/standard.c
gnuplot/src/stats.c
gnuplot/src/stdfn.c
gnuplot/src/strftime.c
gnuplot/src/tables.c
gnuplot/src/tabulate.c
gnuplot/src/term.c
gnuplot/src/time.c
gnuplot/src/unset.c
gnuplot/src/util.c
gnuplot/src/util3d.c
gnuplot/src/variable.c
gnuplot/src/voxelgrid.c
gnuplot/src/vplot.c
gnuplot/src/version.c
    )
endif()

if(IOS)
    target_sources(GnuplotViewerQuickQt6 PRIVATE
            purchasing/ios/iosinapppurchasebackend.h purchasing/ios/iosinapppurchasebackend.mm
            purchasing/ios/iosinapppurchaseproduct.h purchasing/ios/iosinapppurchaseproduct.mm
            purchasing/ios/iosinapppurchasetransaction.h purchasing/ios/iosinapppurchasetransaction.mm
    )

    target_link_libraries(GnuplotViewerQuickQt6 PRIVATE
        "-framework Foundation"
        "-framework StoreKit"
    )
endif()

# Emscripten Toolchain
if (EMSCRIPTEN)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s WASM=1 -s USE_WEBGL2=1 -s FULL_ES3=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=_malloc,_free,lengthBytesUTF8,stringToUTF8")
    #set(CMAKE_EXECUTABLE_SUFFIX ".html")
endif()

target_link_libraries(GnuplotViewerQuickQt6
    PRIVATE Qt6::Core
    PRIVATE Qt6::Gui
    PRIVATE Qt6::Qml
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::CorePrivate
    PRIVATE Qt6::Svg
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Core5Compat
    PRIVATE Qt6::PrintSupport
)

# Bedingte Verlinkung für nicht-WASM Plattformen
#if (NOT EMSCRIPTEN)
#    target_link_libraries(GnuplotViewerQuickQt6 PRIVATE Qt6::HttpServer)
#else()
#    target_link_libraries(GnuplotViewerQuickQt6 PRIVATE Qt6::Widgets)
#endif()

include(GNUInstallDirs)
install(TARGETS GnuplotViewerQuickQt6
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(USE_ANDROID_TOOLS)

    message(STATUS "Using AndroidTools !!!")

    if(ANDROID)
        qt_policy(SET QTP0002 NEW)
        set_property(TARGET GnuplotViewerQuickQt6 APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
            ${CMAKE_CURRENT_SOURCE_DIR}/android)
        add_custom_target(Android SOURCES
            android/AndroidManifest.xml
            android/build.gradle
            android/gradle.properties
        )

        set(QTAT_APP_PERMISSIONS OFF)
        set(QTAT_APK_INFO OFF)
        set(QTAT_SCREEN OFF)
        set(QTAT_SYSTEM OFF)
        set(QTAT_BATTERY_STATE OFF)
        set(QTAT_SIGNAL_STRENGTH OFF)
        set(QTAT_IMAGES OFF)
        set(QTAT_NOTIFICATION OFF)
        set(QTAT_ADMOB_BANNER OFF)
        set(QTAT_ADMOB_INTERSTITIAL OFF)
        set(QTAT_ADMOB_REWARDED_AD OFF)
        set(QTAT_PLAY_STORE OFF)
        set(QTAT_GOOGLE_ACCOUNT OFF)
        set(QTAT_GOOGLE_DRIVE OFF)
        set(QTAT_SHARING ON)
        set(QTAT_USER_MESSAGING_PLATFORM OFF)
        set(QTAT_AUDIO OFF)
        set(QTAT_AUTHENTICATION OFF)
        set(QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
        add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/QtAndroidTools QtAndroidTools)
        target_link_libraries(GnuplotViewerQuickQt6 PRIVATE QtAndroidToolsplugin)
    endif()

else()

    message(STATUS "No AndroidTools")

    if(ANDROID)
        set_property(TARGET GnuplotViewerQuickQt6 PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
            ${CMAKE_CURRENT_SOURCE_DIR}/android)

        #RESOURCES android/AndroidManifest.xml android/build.gradle android/res/values/libs.xml android/res/xml/qtprovider_paths.xml android/gradle/wrapper/gradle-wrapper.jar android/gradle/wrapper/gradle-wrapper.properties android/gradle.properties android/gradlew android/gradlew.bat

    endif()

endif()

#if (NOT EMSCRIPTEN)
#    add_subdirectory(tests)
#    add_subdirectory(tests_qml/QtQuickMemoQmlTests)
#    add_subdirectory(server_app/QtQuickMemoServer)
#endif()

target_compile_definitions(GnuplotViewerQuickQt6 PRIVATE HAVE_CONFIG_H)
