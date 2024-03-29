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
    id: root
    width: 600
    height: 400
    anchors.fill: parent
    focusPolicy: Qt.StrongFocus
    focus: true
    title: qsTr("Gnuplot Output")

    property alias btnGraphics: btnGraphics
    property alias btnHelp: btnHelp
    property alias btnInput: btnInput
    property alias txtOutput: txtOutput

    property string fontName: "Courier"

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
        clip: true
        anchors.top: lblOutput.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        // see Qt documentation TextEdit
        function ensureVisible(r)
        {
            if (scrollView.contentItem.contentX >= r.x)
                scrollView.contentItem.contentX = r.x;
            else if (scrollView.contentItem.contentX+width <= r.x+r.width)
                scrollView.contentItem.contentX = r.x+r.width-width;
            if (scrollView.contentItem.contentY >= r.y)
                scrollView.contentItem.contentY = r.y;
            else if (scrollView.contentItem.contentY+height <= r.y+r.height)
                scrollView.contentItem.contentY = r.y+r.height-height;
        }

        TextEdit/*Area*/ {
            id: txtOutput
            color: settings.isDarkStyle ? "white" : "black"
            text: "   "
            focus: true
            onCursorRectangleChanged: scrollView.ensureVisible(cursorRectangle)
            //placeholderText: qsTr("Outputs from gnuplot commands are shown here")
            anchors.fill: parent
            /*
            anchors.top: lblOutput.bottom
            anchors.right: parent.right
            anchors.bottom: gridButtons.top
            anchors.left: parent.left
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            */
            font.family: fontName
            readOnly: true
            inputMethodHints: Qt.ImhNoAutoUppercase
            //selectByMouse: !readOnly
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
