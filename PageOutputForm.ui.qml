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
    width: 600
    height: 400
    property alias btnGraphics: btnGraphics
    property alias btnHelp: btnHelp
    property alias btnInput: btnInput
    property alias txtOutput: txtOutput

    property string fontName: "Courier"

    anchors.fill: parent
    title: qsTr("Gnuplot Output")

    Label {
        id: lblOutput
        text: qsTr("Output")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    ScrollView {
        id: scrollView
        anchors.top: lblOutput.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextArea {
            id: txtOutput
            placeholderText: qsTr("Outputs from gnuplot commands are shown here")
            anchors.fill: parent
            font.family: fontName
            readOnly: true
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: 50
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
            id: btnHelp
            text: qsTr("Help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnGraphics
            text: qsTr("Graphics")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
