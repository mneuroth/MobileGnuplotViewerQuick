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
import QtQuick.Controls 2.1

Page {
    //id: settingsDialog
    anchors.fill: parent

    title: qsTr("Gnuplot Settings")

    width: 400
    height: 400
    property alias txtGraphicsFontSize: txtGraphicsFontSize
    property alias lblExampleText: lblExampleText
    property alias btnOk: btnOk
    property alias btnCancel: btnCancel
    property alias txtGraphicsResolution: txtGraphicsResolution
    property alias txtSupportLevel: txtSupportLevel
    property alias lblSupportLevel: lblSupportLevel
    property alias btnSelectFont: btnSelectFont
    property alias chbUseGnuplotBeta: chbUseGnuplotBeta
    property alias chbUseLocalFiledialog: chbUseLocalFiledialog

    Rectangle {
        id: rectangle
        color: "#ffffff"
        anchors.rightMargin: 0
        anchors.bottomMargin: 1
        anchors.leftMargin: 0
        anchors.topMargin: -1
        anchors.fill: parent

        Button {
            id: btnCancel
            x: 156
            y: 352
            text: qsTr("Cancel")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
        }

        Button {
            id: btnOk
            y: 355
            text: qsTr("Accept")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
        }

        CheckBox {
            id: chbUseGnuplotBeta
            enabled: settings.supportLevel>=0
            text: qsTr("Use gnuplot beta version")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        CheckBox {
            id: chbUseLocalFiledialog
            visible: applicationData.isWASM
            height: applicationData.isWASM ? chbUseGnuplotBeta.height : 0
            text: qsTr("Use local filedialog")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbUseGnuplotBeta.bottom
            anchors.topMargin: 5
        }

        TextField {
            id: txtGraphicsResolution
            width: 100
            height: 40
            anchors.top: chbUseLocalFiledialog.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblGraphicsResolution
            y: 118
            text: qsTr("Resolution for graphic area")
            anchors.verticalCenter: txtGraphicsResolution.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: txtGraphicsResolution.right
            anchors.leftMargin: 5
        }

        TextField {
            id: txtGraphicsFontSize
            width: 100
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: txtGraphicsResolution.bottom
            anchors.topMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblGraphicsFontSize
            y: 172
            text: qsTr("Font size for graphic area")
            anchors.verticalCenter: txtGraphicsFontSize.verticalCenter
            anchors.left: txtGraphicsFontSize.right
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
        }

        TextField {
            id: txtSupportLevel
            readOnly: true
            width: 100
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: txtGraphicsFontSize.bottom
            anchors.topMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblSupportLevel
            y: 172
            text: qsTr("SupportLevel")
            anchors.verticalCenter: txtSupportLevel.verticalCenter
            anchors.left: txtSupportLevel.right
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
        }

        Button {
            id: btnSelectFont
            text: qsTr("Text font")
            anchors.top: txtSupportLevel.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
        }

        Label {
            id: lblExampleText
            y: 64
            text: qsTr("This is an example text for the current font")
            anchors.verticalCenter: btnSelectFont.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: btnSelectFont.right
            anchors.leftMargin: 5
        }
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:156}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
}
##^##*/

