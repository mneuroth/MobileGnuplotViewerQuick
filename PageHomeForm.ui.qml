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

    property alias btnRun: btnRun
    property alias btnOpen: btnOpen
    property alias textArea: textArea
    property alias btnGraphics: btnGraphics
    property alias lblFileName: lblFileName
    property alias btnSave: btnSave
    property alias btnHelp: btnHelp
    property alias btnOutput: btnOutput
    property alias gridButtons: gridButtons

    property string fontName: "Courier"

    title: qsTr("Gnuplot Input")

    Label {
        id: lblFileName
        height: 14
        text: qsTr("unknown")
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
        anchors.top: lblFileName.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextEdit/*Area*/ {
            id: textArea
            font.family: fontName
            anchors.fill: scrollView
            objectName: "textArea"
            //placeholderText: qsTr("Enter gnuplot script here...")
            //selectByMouse: !readOnly
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: 95
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        rows: 2
        columns: 3

        Button {
            id: btnOpen
            text: qsTr("Open")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnSave
            text: qsTr("Save")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnRun
            text: qsTr("Run")
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Button {
            id: btnGraphics
            text: qsTr("Graphics")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnHelp
            text: qsTr("Help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnOutput
            text: qsTr("Output")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    states: [
        State {
            name: "State1"
        }
    ]
}

/*##^##
Designer {
    D{i:1;anchors_width:605;anchors_x:21;anchors_y:16}D{i:3;anchors_height:227;anchors_width:630;anchors_x:5;anchors_y:5}
D{i:2;anchors_height:400;anchors_width:200;anchors_x:0;anchors_y:0}D{i:7;anchors_x:111;anchors_y:311}
D{i:9;anchors_x:217;anchors_y:436}D{i:4;anchors_height:400;anchors_x:5;anchors_y:5}
}
##^##*/

