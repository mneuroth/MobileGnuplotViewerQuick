import QtQuick 2.12
import QtQuick.Controls 2.5
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
    property alias btnNew: btnNew
    property alias btnSave: btnSave
    property alias btnSaveAs: btnSaveAs
    property alias btnShare: btnShare
    property alias btnHelp: btnHelp
    property alias btnOutput: btnOutput
    property alias gridButtons: gridButtons

    title: qsTr("Gnuplot")

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
        anchors.top: lblFileName.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        TextArea {
            id: textArea
            anchors.fill: parent
            objectName: "textArea"
            placeholderText: qsTr("Enter gnuplot script here...")
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: 135
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        rows: 3
        columns: 3

        Button {
            id: btnOpen
            text: qsTr("Open")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnNew
            text: qsTr("New")
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
            id: btnShare
            text: qsTr("Share")
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
            id: btnSaveAs
            text: qsTr("Save as")
            Layout.fillHeight: true
            Layout.fillWidth: true
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
D{i:9;anchors_x:217;anchors_y:436}D{i:10;anchors_x:323;anchors_y:435}D{i:11;anchors_width:605;anchors_x:110;anchors_y:436}
D{i:4;anchors_height:400;anchors_x:5;anchors_y:5}
}
##^##*/

