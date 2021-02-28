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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

Page {
    id: root
    anchors.fill: parent

    title: qsTr("About")

    property alias lblIconInfos: lblIconInfos
    property alias btnClose: btnClose
    property alias lblAppName: lblAppName
    property alias lblAppVersion: lblAppVersion
    property alias lblAppDate: lblAppDate
    property alias lblAppAuthor: lblAppAuthor
    property alias lblAppInfos: lblAppInfos
    property alias lblGithubPage: lblGithubPage

    ScrollView {
        id: scrollView

        anchors.fill: parent
        //anchors.margins: 10

        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: layout

            width: root.width

            Text {
                id: lblAppName
                text: "<a href='https://play.google.com/store/apps/details?id=de.mneuroth.gnuplotviewerquick'>MobileGnuplotViewerQuick</a>"
                fontSizeMode: Text.FixedSize
                font.pixelSize: 24
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: 10
            }

            Image {
                id: image
                //height: 40
                //width: height
                //fillMode: Image.PreserveAspectFit
                source: "gnuplotviewer_flat_512x512.png"
                Layout.alignment: Qt.AlignCenter
                Layout.maximumWidth: 100
                Layout.maximumHeight: 100
            }

            Text {
                id: lblAppVersion
                text: qsTr("Version: 2.0.11")
                Layout.alignment: Qt.AlignCenter
            }

            Text {
                id: lblAppDate
                text: qsTr("from: 28.2.2021")
                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 15
            }

            Text {
                id: lblAppAuthor
                text: qsTr("Author: Michael Neuroth")
                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 15
            }

            Text {
                id: lblGithubPage
                text: qsTr("<a href='https://github.com/mneuroth/MobileGnuplotViewerQuick'>Github page for MobileGnuplotViewerQuick</a>")
                Layout.alignment: Qt.AlignCenter
            }

            Text {
                id: lblIconInfos
                text: qsTr("<a href='http://www.flaticon.com'>Icons designed by Flaticon</a>")
                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 15
            }

            Text {
                id: lblAppInfos
                text: qsTr("App Infos")
                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 15
            }

            Button {
                id: btnClose
                text: qsTr("Close")
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:49;anchors_y:324}D{i:3;anchors_x:49}D{i:4;anchors_x:49}D{i:5;anchors_x:49}
D{i:6;anchors_x:45}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
}
##^##*/

