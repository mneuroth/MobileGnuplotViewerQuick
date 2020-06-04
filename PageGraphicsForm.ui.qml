import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Page {
    property alias image: image
    property alias imageMouseArea: imageMouseArea

    width: 600
    height: 400
    property alias btnHelp: btnHelp
    property alias btnOutput: btnOutput
    property alias btnInput: btnInput
    property alias btnExport: btnExport
    property alias btnClear: btnClear
    property alias btnShare: btnShare
    anchors.fill: parent
    title: qsTr("Graphics")

    Image {
        id: image
        x: 5
        y: 5
        width: parent.width - 10
        height: parent.height - 10 - gridButtons.height
        //anchors.fill: parent
        objectName: "imageArea"
        // TODO: see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
        source: "DSC_4945.JPG" // "spaceship.svg" // "empty.svg"
        fillMode: Image.PreserveAspectFit
        // TODO: https://forum.qt.io/topic/112192/zooming-an-svg-image
    }

    PinchArea {
        id: imagePinchArea
        anchors.bottom: gridButtons.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottomMargin: 5
        pinch.target: image
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        //pinch.minimumRotation: -360
        //pinch.maximumRotation: 360
        pinch.dragAxis: Pinch.XAndYAxis

        MouseArea {
            id: imageMouseArea
            hoverEnabled: true
            anchors.fill: parent
            drag.target: image
            scrollGestureEnabled: false // 2-finger-flick gesture should pass through to the Flickable
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
            id: btnShare
            text: qsTr("Share")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnClear
            text: qsTr("Clear")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnExport
            text: qsTr("Export")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

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
            id: btnHelp
            text: qsTr("Help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}

/*##^##
Designer {
    D{i:1;anchors_height:400;anchors_width:600;anchors_x:5;anchors_y:5}D{i:2;anchors_x:5;anchors_y:5}
}
##^##*/

