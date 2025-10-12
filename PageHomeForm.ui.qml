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
    width: 600
    height: 400
    anchors.fill: parent
    focusPolicy: Qt.StrongFocus
    focus: true
    title: qsTr("Gnuplot Input")

    property alias btnRun: btnRun
    property alias btnOpen: btnOpen
    property alias textArea: textArea
    property alias textLineNumbers: textLineNumbers
    property alias btnGraphics: btnGraphics
    property alias lblFileName: lblFileName
    property alias btnSave: btnSave
    property alias btnHelp: btnHelp
    property alias btnOutput: btnOutput
    property alias gridButtons: gridButtons

    property string fontName: "Courier"

    property int numberColumnWidth: 35  //org: 50

    property int buttonWidth: 100

    Label {
        id: lblFileName
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

        RowLayout {
            id: textRow
            anchors.fill: parent

            Rectangle {
                id: lineNumbersBackground
                color: "light grey"
                visible: settings.showLineNumbers
                Layout.fillHeight: true
                Layout.minimumWidth: numberColumnWidth
                Layout.preferredWidth: numberColumnWidth
                Layout.maximumWidth: numberColumnWidth
                height: textArea.height

                TextEdit {
                    id: textLineNumbers
                    font.family: fontName
                    horizontalAlignment: TextEdit.AlignRight
                    readOnly: true
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    text: ""
                }
            }

            // TextArea problem: if switch to readonly --> cursor and view jumps to the end of the text ???
            TextEdit/*Area*/ {
                id: textArea
                font.family: fontName
                //anchors.fill: parent
                Layout.fillWidth: true
                Layout.fillHeight: true

                objectName: "textArea"
                //placeholderText: qsTr("Enter gnuplot script here...")
                //selectByMouse: !readOnly
                text: "   "
                inputMethodHints: Qt.ImhNoAutoUppercase
                onCursorRectangleChanged: scrollView.ensureVisible(cursorRectangle)
            }
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: !settings.useToolBar ? 95 : 0
        visible: !settings.useToolBar
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
            Layout.preferredWidth: buttonWidth
        }

        Button {
            id: btnSave
            text: qsTr("Save")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: buttonWidth
        }

        Button {
            id: btnRun
            text: qsTr("Run")
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth
        }

        Button {
            id: btnGraphics
            text: qsTr("Graphics")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: buttonWidth
        }

        Button {
            id: btnHelp
            text: qsTr("Help")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: buttonWidth
        }

        Button {
            id: btnOutput
            text: qsTr("Output")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: buttonWidth
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

