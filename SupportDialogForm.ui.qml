
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
import QtQuick.Controls 2.1

Page {
    property alias btnSupportLevel0: btnSupportLevel0
    property alias btnSupportLevel1: btnSupportLevel1
    property alias btnSupportLevel2: btnSupportLevel2
    property alias btnClose: btnClose
    property alias lblLevel0: lblLevel0
    property alias lblLevel1: lblLevel1
    property alias lblLevel2: lblLevel2
    property alias lblGooglePlay: lblGooglePlay
    property alias lblSupporterOfClassicVersion: lblSupporterOfClassicVersion

    anchors.fill: parent

    title: qsTr("Support")

    Rectangle {
        id: rectangle
        color: "#ffffff"
        anchors.fill: parent

        Row {
            id: row0

            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: lblSupportInfo.bottom
            anchors.topMargin: 5
            spacing: 10

            Button {
                id: btnSupportLevel0
                x: 30
                text: qsTr("Support Level Bronze")
                width: parent.width * 2 / 3
            }

            Label {
                id: lblLevel0
                y: 18
                text: "?"
                anchors.verticalCenter: btnSupportLevel0.verticalCenter
            }
        }

        Row {
            id: row1

            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: row0.bottom
            anchors.topMargin: 5
            spacing: 10

            Button {
                id: btnSupportLevel1
                text: qsTr("Support Level Silver")
                width: parent.width * 2 / 3
            }

            Label {
                id: lblLevel1
                y: 18
                text: "?"
                anchors.verticalCenter: btnSupportLevel1.verticalCenter
            }
        }

        Row {
            id: row2

            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: row1.bottom
            anchors.topMargin: 5
            spacing: 10

            Button {
                id: btnSupportLevel2
                text: qsTr("Support Level Gold")
                width: parent.width * 2 / 3
            }

            Label {
                id: lblLevel2
                y: 18
                text: "?"
                anchors.verticalCenter: btnSupportLevel2.verticalCenter
            }
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

        Text {
            id: lblSupportInfo
            text: qsTr("<body>The development of this app can be supported in various ways:<br><ul><li>giving feedback and rating via the store enty in Google Play</li><li>purchasing a support level item via in app purchase (see buttons below)</li></ul><br>Purchasing any support level will give you some more features:<br><ul><li>usage of the latest Gnuplot (beta) version is enabled</li><li>sharing as PDF/PNG is enabled</li><li>nice support icon is visible in title bar of the application</li></ul></body>")
            wrapMode: Text.WordWrap
            enabled: false
            //horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        Text {
            id: lblGooglePlay
            //y: 18
            text: "<a href='https://play.google.com/store/apps/details?id=de.mneuroth.gnuplotviewerquick'>MobileGnuplotViewerQuick in Google Play</a>"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: row2.bottom
            anchors.topMargin: 15
        }

        Text {
            id: lblSupporterOfClassicVersion
            text: qsTr("You already supported the predecessor of this application !")
            visible: applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: lblGooglePlay.bottom
            anchors.topMargin: 15
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_x:30;anchors_y:41}D{i:6;anchors_x:391}
D{i:9;anchors_x:215;anchors_y:5}D{i:1;anchors_height:200;anchors_width:200;anchors_x:108;anchors_y:91}
}
##^##*/

