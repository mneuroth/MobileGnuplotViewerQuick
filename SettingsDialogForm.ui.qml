/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    anchors.fill: parent

    focusPolicy: Qt.StrongFocus
    focus: true

    title: qsTr("Gnuplot Settings")

    property int editFieldWidth: 75
    property int minFontSize: 6
    property int maxFontSize: 64
    property int minGraphicSize: 128
    property int maxGraphicSize: 4096

    property alias txtGraphicsFontSize: txtGraphicsFontSize
    property alias txtTextFontSize: txtTextFontSize
    property alias btnDecTextFontSize: btnDecTextFontSize
    property alias btnIncTextFontSize: btnIncTextFontSize
    property alias lblExampleText: lblExampleText
    property alias btnOk: btnOk
    property alias btnCancel: btnCancel
    property alias btnRestoreDefaultSettings: btnRestoreDefaultSettings
    property alias txtGraphicsResolutionX: txtGraphicsResolutionX
    property alias txtGraphicsResolutionY: txtGraphicsResolutionY
    property alias txtSupportLevel: txtSupportLevel
    property alias lblSupportLevel: lblSupportLevel
    property alias btnSelectFont: btnSelectFont
    property alias chbUseGnuplotBeta: chbUseGnuplotBeta
    property alias chbUseToolBar: chbUseToolBar
    property alias chbUseSyntaxHighlighter: chbUseSyntaxHighlighter
    property alias chbShowLineNumbers: chbShowLineNumbers
    property alias chbUseLocalFiledialog: chbUseLocalFiledialog
    property alias chbSyncXAndYResolution: chbSyncXAndYResolution
    property alias txtAppStyle: txtAppStyle

    ScrollView {
        id: scrollView

        anchors.fill: parent
        anchors.margins: defaultMargins

        //contentWidth: lblSupportInfo.contentWidth // btnSupportLevel1.width //availableWidth
        contentHeight: layout.implicitHeight + 50
        //clip: true

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: layout
            Layout.preferredHeight: 50

            CheckBox {
                id: chbUseGnuplotBeta
                enabled: /*not available for embedded gnuplot*/false && settings.supportLevel>=0
                text: qsTr("Use latest Gnuplot (beta) version")
                Layout.preferredHeight: defaultButtonHeight
            }

            CheckBox {
                id: chbShowLineNumbers
                enabled: true
                text: qsTr("Show line numbers")
                Layout.preferredHeight: defaultButtonHeight
            }

            CheckBox {
                id: chbUseToolBar
                enabled: true
                text: qsTr("Show toolbar")
                Layout.preferredHeight: defaultButtonHeight
            }


            CheckBox {
                id: chbUseSyntaxHighlighter
                enabled: true
                text: qsTr("Use syntax highlighting")
                Layout.preferredHeight: defaultButtonHeight
            }

            CheckBox {
                id: chbUseLocalFiledialog
                text: qsTr("Use local filedialog")
                visible: applicationData !== null ? applicationData.isWASM : false
                height: applicationData !== null ? (applicationData.isWASM ? chbUseGnuplotBeta.height : 0) : 0
                Layout.preferredHeight: defaultButtonHeight
            }

            CheckBox {
                id: chbSyncXAndYResolution
                checked: true
                text: qsTr("Synchronize x and y resolution")
                Layout.preferredHeight: defaultButtonHeight
            }

            Row {
                id: rowSyncXAndYResolution
                spacing: 5

                TextField {
                    id: txtGraphicsResolutionX
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    validator: IntValidator {bottom: minGraphicSize; top: maxGraphicSize}
                    width: editFieldWidth
                    height: defaultButtonHeight
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsResolutionX
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("x resolution for graphic area")
                    anchors.verticalCenter: txtGraphicsResolutionX.verticalCenter
                }

            }

            Row {
                id: rowResolutionY
                spacing: 5

                TextField {
                    id: txtGraphicsResolutionY
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    enabled: !chbSyncXAndYResolution.checked
                    validator: IntValidator {bottom: minGraphicSize; top: maxGraphicSize}
                    width: editFieldWidth
                    height: defaultButtonHeight
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsResolutionY
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("y resolution for graphic area")
                    anchors.verticalCenter: txtGraphicsResolutionY.verticalCenter
                }
            }

            Row {
                id: rowGraphicsFontSize
                spacing: 5

                TextField {
                    id: txtGraphicsFontSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    validator: IntValidator { bottom: minFontSize; top: maxFontSize }
                    width: editFieldWidth
                    height: defaultButtonHeight
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsFontSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Font size for graphic area")
                    anchors.verticalCenter: txtGraphicsFontSize.verticalCenter
                }
            }

            Row {
                id: rowAppStyle
                spacing: 5

                ComboBox {
                     model: ['Default', 'Basic', 'Fusion', 'Imagine', 'Universal', 'Material', 'Material Dark', 'Android'] // optional: macOS, Windows
                     height: defaultButtonHeight
                }

                TextField {
                    id: txtAppStyle
                    width: editFieldWidth
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    height: defaultButtonHeight
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblAppStyle
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Application style")
                    anchors.verticalCenter: txtAppStyle.verticalCenter
                }
            }

            Row {
                id: rowTextFontSize
                spacing: 5

                TextField {
                    id: txtTextFontSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    validator: IntValidator { bottom: minFontSize; top: maxFontSize }
                    width: editFieldWidth
                    height: defaultButtonHeight
                    placeholderText: qsTr("")
                }

                Button {
                    id: btnIncTextFontSize
                    text: "+"
                    height: defaultButtonHeight
                    width: defaultButtonHeight
                }

                Button {
                    id: btnDecTextFontSize
                    text: "-"
                    height: defaultButtonHeight
                    width: defaultButtonHeight
                }

                Label {
                    id: lblTextFontSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Font size for text area")
                    anchors.verticalCenter: txtTextFontSize.verticalCenter
                    height: defaultButtonHeight
                }
            }

            Row {
                id: rowSupportLevel
                spacing: 5

                TextField {
                    id: txtSupportLevel
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    readOnly: true
                    visible: isAppStoreSupported
                    width: editFieldWidth
                    //height: buttonHeight
                    //height: isAppStoreSupported ? implicitHeight : 0
                    height: isAppStoreSupported ? txtGraphicsFontSize.height : 0
                    placeholderText: qsTr("")
                    text: (applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false) ? "99" : settings.supportLevel
                }

                Label {
                    id: lblSupportLevel
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    visible: isAppStoreSupported
                    text: qsTr("SupportLevel")
                    height: isAppStoreSupported ? lblGraphicsFontSize.height : 0
                    anchors.verticalCenter: txtSupportLevel.verticalCenter
                }
            }

            Row {
                id: rowSelectFont
                spacing: 5
                height: btnSelectFont.visible ? implicitHeight : 0

                Button {
                    id: btnSelectFont
                    height: btnSelectFont.visible ? implicitHeight : 0
                    text: qsTr("Text font")
                }

                Label {
                    id: lblExampleText
                    height: btnSelectFont.visible ? implicitHeight : 0
                    text: qsTr("This is an example text for the current font")
                    anchors.verticalCenter: btnSelectFont.verticalCenter
                }
            }

            RowLayout {
                spacing: 10
                width: parent.width

                Button {
                    id: btnOk
                    text: qsTr("Accept")
                    //Layout.fillHeight: true
                    //Layout.fillWidth: true
                    Layout.preferredWidth: defaultButtonWidth
                    Layout.preferredHeight: defaultButtonHeight
                }

                Button {
                    id: btnCancel
                    text: qsTr("Cancel")
                    //height: defaultButtonHeight
                    //Layout.fillHeight: true
                    //Layout.fillWidth: true
                    Layout.preferredWidth: defaultButtonWidth
                    Layout.preferredHeight: defaultButtonHeight
                }

                Button {
                    id: btnRestoreDefaultSettings
                    text: qsTr("Default Values")
                    //height: defaultButtonHeight
                    //Layout.fillHeight: true
                    //Layout.fillWidth: true
                    Layout.preferredWidth: defaultButtonWidth
                    Layout.preferredHeight: defaultButtonHeight
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:156}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
}
##^##*/

