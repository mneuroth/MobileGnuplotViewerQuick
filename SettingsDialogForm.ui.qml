/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

Page {
    id: root
    anchors.fill: parent

    title: qsTr("Gnuplot Settings")

    property int editFieldWidth: 75

    property alias txtGraphicsFontSize: txtGraphicsFontSize
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

    ScrollView {
        id: scrollView

        anchors.fill: parent
        anchors.margins: 10

        //contentWidth: lblSupportInfo.contentWidth // btnSupportLevel1.width //availableWidth
        contentHeight: layout.implicitHeight + 50
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: layout

            CheckBox {
                id: chbUseGnuplotBeta
                enabled: /*not available for embedded gnuplot*/false && settings.supportLevel>=0
                text: qsTr("Use latest Gnuplot (beta) version")
            }

            CheckBox {
                id: chbShowLineNumbers
                enabled: true
                text: qsTr("Show line numbers")
            }

            CheckBox {
                id: chbUseToolBar
                enabled: true
                text: qsTr("Show toolbar")
            }


            CheckBox {
                id: chbUseSyntaxHighlighter
                enabled: true
                text: qsTr("Use syntax highlighting")
            }

            CheckBox {
                id: chbUseLocalFiledialog
                text: qsTr("Use local filedialog")
            }

            CheckBox {
                id: chbSyncXAndYResolution
                checked: true
                text: qsTr("Synchronize x and y resolution")
            }

            Row {
                id: rowSyncXAndYResolution
                spacing: 5

                anchors.top: chbSyncXAndYResolution.bottom
                anchors.topMargin: 10

                TextField {
                    id: txtGraphicsResolutionX
                    validator: IntValidator {bottom: 1; top: 4096}
                    width: editFieldWidth
                    height: 40
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsResolutionX
                    text: qsTr("x resolution for graphic area")
                    anchors.verticalCenter: txtGraphicsResolutionX.verticalCenter
                }

            }

            Row {
                id: rowResolutionY
                spacing: 5

                anchors.top: rowSyncXAndYResolution.bottom
                anchors.topMargin: 10

                TextField {
                    id: txtGraphicsResolutionY
                    enabled: !chbSyncXAndYResolution.checked
                    validator: IntValidator {bottom: 1; top: 4096}
                    width: editFieldWidth
                    height: 40
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsResolutionY
                    text: qsTr("y resolution for graphic area")
                    anchors.verticalCenter: txtGraphicsResolutionY.verticalCenter
                }
            }

            Row {
                id: rowGraphicsFontSize
                spacing: 5

                anchors.top: rowResolutionY.bottom
                anchors.topMargin: 10

                TextField {
                    id: txtGraphicsFontSize
                    validator: IntValidator {bottom: 1; top: 256}
                    width: editFieldWidth
                    height: 40
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblGraphicsFontSize
                    text: qsTr("Font size for graphic area")
                    anchors.verticalCenter: txtGraphicsFontSize.verticalCenter
                }
            }

            Row {
                id: rowSupportLevel
                spacing: 5

                anchors.top: rowGraphicsFontSize.bottom
                anchors.topMargin: 10

                TextField {
                    id: txtSupportLevel
                    readOnly: true
                    width: editFieldWidth
                    height: 40
                    placeholderText: qsTr("")
                }

                Label {
                    id: lblSupportLevel
                    text: qsTr("SupportLevel")
                    anchors.verticalCenter: txtSupportLevel.verticalCenter
                }
            }

            Row {
                id: rowSelectFont
                spacing: 5
                height: btnSelectFont.visible ? implicitHeight : 0

                anchors.top: rowSupportLevel.bottom
                anchors.topMargin: 10

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

            Row {
                spacing: 10

                anchors.top: rowSelectFont.bottom
                anchors.topMargin: 10

                Button {
                    id: btnOk
                    text: qsTr("Accept")
                }

                Button {
                    id: btnCancel
                    text: qsTr("Cancel")
                }

                Button {
                    id: btnRestoreDefaultSettings
                    text: qsTr("Default Values")
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

