import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page
    //width: 600
    //height: 400
    property alias btnRun: btnRun
    property alias btnExit: btnExit
    property alias btnOpen: btnOpen
    property alias textArea: textArea
    property alias btnGraphics: btnGraphics
    property alias lblFileName: lblFileName
    property alias btnClear: btnClear

    title: qsTr("Gnuplot")

    ScrollView {
        id: scrollView
        anchors.top: lblFileName.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 96

        TextArea {
            id: textArea
            anchors.fill: parent
            objectName: "textArea"
            anchors.bottom: btnOpen.top
            placeholderText: qsTr("Text Area")
        }
    }

    Button {
        id: btnOpen
        x: 5
        text: qsTr("Open")
        anchors.top: scrollView.bottom
        anchors.topMargin: 6
    }

    Button {
        id: btnExit
        x: 5
        text: qsTr("Exit")
        anchors.top: btnOpen.bottom
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }

    Button {
        id: btnRun
        text: qsTr("Run")
        anchors.left: btnOpen.right
        anchors.leftMargin: 5
        anchors.top: scrollView.bottom
        anchors.topMargin: 6
    }

    Button {
        id: btnGraphics
        text: qsTr("Graphics")
        anchors.left: btnExit.right
        anchors.leftMargin: 5
        anchors.top: btnRun.bottom
        anchors.topMargin: 5
    }

    Label {
        id: lblFileName
        height: 14
        text: qsTr("Label")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    Button {
        id: btnClear
        x: 216
        y: 390
        text: qsTr("Clear")
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_height:307;anchors_x:5;anchors_y:5}
D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}D{i:3;anchors_y:300}
D{i:4;anchors_y:355}D{i:5;anchors_x:111;anchors_y:311}D{i:6;anchors_x:110;anchors_y:436}
D{i:7;anchors_width:605;anchors_x:21;anchors_y:16}
}
##^##*/

