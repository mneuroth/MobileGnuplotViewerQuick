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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Page {
    id: page
    width: 600
    height: 400
    anchors.fill: parent

    property alias btnOutput: btnOutput
    property alias btnInput: btnInput
    property alias btnRunHelp: btnRunHelp
    property alias txtHelp: txtHelp

    property string fontName: "Courier"

    title: qsTr("Gnuplot Help")

    Label {
        id: lblHelp
        text: qsTr("Help")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    ScrollView {
        id: scrollView
        clip: true
        anchors.top: lblHelp.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextEdit/*Area*/ {
            id: txtHelp
            anchors.fill: parent
            font.family: fontName
            text: qsTr("help # enter any help command here and press the run button")
            inputMethodHints: Qt.ImhNoAutoUppercase
            //placeholderText: qsTr("Enter gnuplot help command here (e. g. help plot)\nand activate \"Run help\" button")
            //selectByMouse: readOnly
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: !settings.useToolBar ? 50 : 0
        visible: !settings.useToolBar
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        rows: 1
        columns: 3

        Button {
            id: btnInput
            text: qsTr("Input")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnOutput
            text: qsTr("Output")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnRunHelp
            text: qsTr("Run help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
