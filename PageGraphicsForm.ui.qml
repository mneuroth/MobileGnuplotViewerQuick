/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Page {
    id: page
    property alias image: image
    property alias imageMouseArea: imageMouseArea

    width: 600
    height: 400
    property alias lblShowGraphicsInfo: lblShowGraphicsInfo
    property alias btnHelp: btnHelp
    property alias btnOutput: btnOutput
    property alias btnInput: btnInput
    anchors.fill: parent
    title: qsTr("Gnuplot Graphics")

    Image {
        id: image
        x: 5
        y: 5
        width: parent.width - 10
        height: parent.height - 15 - gridButtons.height - lblShowGraphicsInfo.height
        objectName: "imageArea"
        // TODO: see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
        source: "/empty.svg"
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
            scrollGestureEnabled: false

            // 2-finger-flick gesture should pass through to the Flickable
        }
    }

    Label {
        id: lblShowGraphicsInfo
        y: 276
        height: 14
        text: qsTr("Infos...")
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.bottom: gridButtons.top
        anchors.bottomMargin: 5
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
            id: btnOutput
            text: qsTr("Output")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}

/*##^##
Designer {
    D{i:1;anchors_height:290;anchors_width:590;anchors_x:5;anchors_y:5}D{i:2;anchors_x:5;anchors_y:5}
D{i:4;anchors_width:587;anchors_x:8}
}
##^##*/

