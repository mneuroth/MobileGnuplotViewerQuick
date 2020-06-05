
/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2

Page {
    id: aboutDialog
    anchors.fill: parent

    width: 400
    height: 400
    property alias btnClose: btnClose
    property alias lblAppName: lblAppName
    property alias lblAppVersion: lblAppVersion
    property alias lblAppDate: lblAppDate
    property alias lblAppAuthor: lblAppAuthor
    property alias lblAppInfos: lblAppInfos

    Rectangle {
        id: rectangle
        color: "#ffffff"
        anchors.rightMargin: 0
        anchors.bottomMargin: 1
        anchors.leftMargin: 0
        anchors.topMargin: -1
        anchors.fill: parent

        Text {
            id: lblAppInfos
            x: 5
            y: 324
            text: qsTr("App Infos")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
        }

        Text {
            id: lblAppAuthor
            x: 5
            y: 290
            text: qsTr("Author: Michael Neuroth")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
        }

        Text {
            id: lblAppDate
            x: 5
            y: 245
            text: qsTr("from: 5.6.2020")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
        }

        Text {
            id: lblAppVersion
            x: 5
            y: 219
            text: qsTr("Version: 2.0.0")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
        }

        Text {
            id: lblAppName
            x: 5
            y: 18
            text: qsTr("MobileGnuplotViewerQuick")
            fontSizeMode: Text.FixedSize
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 18
        }

        Image {
            id: image
            y: 46
            height: 162
            anchors.right: parent.right
            anchors.rightMargin: 90
            anchors.left: parent.left
            anchors.leftMargin: 90
            fillMode: Image.PreserveAspectFit
            source: "gnuplotviewer512x512.png"
        }

        Button {
            id: btnClose
            x: 156
            y: 352
            text: qsTr("Close")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
        }
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:49}D{i:3;anchors_x:49}D{i:4;anchors_x:49}D{i:5;anchors_x:49}D{i:6;anchors_x:45}
D{i:8;anchors_x:156}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
}
##^##*/

