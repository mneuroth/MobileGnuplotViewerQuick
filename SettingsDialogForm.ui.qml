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

    property int editFieldWidth: 75

    property alias txtGraphicsFontSize: txtGraphicsFontSize
    property alias lblExampleText: lblExampleText
    property alias btnOk: btnOk
    property alias btnCancel: btnCancel
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
            text: qsTr("Cancel")
            anchors.left: btnOk.right
            anchors.leftMargin: 10
            anchors.top: txtSupportLevel.bottom
            anchors.topMargin: 10
        }

        Button {
            id: btnOk
            text: qsTr("Accept")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: txtSupportLevel.bottom
            anchors.topMargin: 10
        }

        CheckBox {
            id: chbUseGnuplotBeta
            enabled: /*not available for embedded gnuplot*/false && settings.supportLevel>=0
            text: qsTr("Use latest Gnuplot (beta) version")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        CheckBox {
            id: chbShowLineNumbers
            enabled: true
            text: qsTr("Show line numbers")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbUseGnuplotBeta.bottom
            anchors.topMargin: 5
        }

        CheckBox {
            id: chbUseToolBar
            enabled: true
            text: qsTr("Show toolbar")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbShowLineNumbers.bottom
            anchors.topMargin: 5
        }


        CheckBox {
            id: chbUseSyntaxHighlighter
            enabled: true
            text: qsTr("Use syntax highlighting")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbUseToolBar.bottom
            anchors.topMargin: 5
        }

        CheckBox {
            id: chbUseLocalFiledialog
            visible: applicationData !== null ? applicationData.isWASM : false
            height: applicationData !== null ? (applicationData.isWASM ? chbUseGnuplotBeta.height : 0) : 0
            text: qsTr("Use local filedialog")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbUseSyntaxHighlighter.bottom
            anchors.topMargin: 5
        }

        CheckBox {
            id: chbSyncXAndYResolution
            checked: true
            text: qsTr("Synchronize x and x resolution")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: chbUseLocalFiledialog.bottom
            anchors.topMargin: 5
        }

        TextField {
            id: txtGraphicsResolutionX
            validator: IntValidator {bottom: 1; top: 4096}
            width: editFieldWidth
            height: 40
            anchors.top: chbSyncXAndYResolution.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblGraphicsResolutionX
            text: qsTr("x resolution for graphic area")
            anchors.verticalCenter: txtGraphicsResolutionX.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: txtGraphicsResolutionX.right
            anchors.leftMargin: 5
        }

        TextField {
            id: txtGraphicsResolutionY
            enabled: !chbSyncXAndYResolution.checked
            validator: IntValidator {bottom: 1; top: 4096}
            width: editFieldWidth
            height: 40
            anchors.top: txtGraphicsResolutionX.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblGraphicsResolutionY
            text: qsTr("y resolution for graphic area")
            anchors.verticalCenter: txtGraphicsResolutionY.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: txtGraphicsResolutionY.right
            anchors.leftMargin: 5
        }

        TextField {
            id: txtGraphicsFontSize
            validator: IntValidator {bottom: 1; top: 256}
            width: editFieldWidth
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: txtGraphicsResolutionY.bottom
            anchors.topMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblGraphicsFontSize
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
            width: editFieldWidth
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: txtGraphicsFontSize.bottom
            anchors.topMargin: 5
            placeholderText: qsTr("")
        }

        Label {
            id: lblSupportLevel
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

