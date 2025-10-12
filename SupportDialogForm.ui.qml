
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
    property alias btnSupportLevel0: btnSupportLevel0
    property alias btnSupportLevel1: btnSupportLevel1
    property alias btnSupportLevel2: btnSupportLevel2
    property alias btnClose: btnClose
    property alias lblLevel0: lblLevel0
    property alias lblLevel1: lblLevel1
    property alias lblLevel2: lblLevel2
    property alias lblSupportInfo: lblSupportInfo
    property alias lblGooglePlay: lblGooglePlay
    property alias lblGithubPage: lblGithubPage
    property alias lblSupporterOfClassicVersion: lblSupporterOfClassicVersion

    anchors.fill: parent

    title: qsTr("Support")

    ScrollView {
        id: scrollView

        anchors.fill: parent
        anchors.margins: defaultMargins

        contentWidth: lblSupportInfo.contentWidth // btnSupportLevel1.width //availableWidth
        //contentHeight: 600
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: layout

            Text {
                id: lblSupportInfo
                text: qsTr("<body>The development of this app can be supported in various ways:<br><ul><li>giving feedback and rating via the store enty in Google Play (see link below)</li><li>giving feedback on the github project page (see link below)</li><li>purchasing a support level item via in app purchase (see buttons below)</li></ul><br>Purchasing any support level will give you some more features:<br><ul><li>sharing as PDF/PNG is enabled</li><li>enable replace, previous and next menu items</li><li>nice support icon is visible in title bar of the application</li></ul></body>")
                //text: qsTr("<body>The development of this app can be supported in various ways:<br><ul><li>giving feedback and rating via the store enty in Google Play</li><li>purchasing a support level item via in app purchase (see buttons below)</li></ul><br>Purchasing any support level will give you some more features:<br><ul><li>usage of the latest Gnuplot (beta) version is enabled</li><li>sharing as PDF/PNG is enabled</li><li>nice support icon is visible in title bar of the application</li></ul></body>")
                wrapMode: Text.WordWrap
                enabled: false
                Layout.bottomMargin: 15
            }

            Row {
                id: row0

                spacing: 10

                Button {
                    id: btnSupportLevel0
                    text: qsTr("Support Level Bronze")
                    width: lblSupportInfo.contentWidth * 0.5
                }

                Label {
                    id: lblLevel0
                    text: "?"
                    anchors.verticalCenter: btnSupportLevel0.verticalCenter
                }
            }

            Row {
                id: row1

                spacing: 10

                Button {
                    id: btnSupportLevel1
                    text: qsTr("Support Level Silver")
                    width: lblSupportInfo.contentWidth * 0.5
                }

                Label {
                    id: lblLevel1
                    text: "?"
                    anchors.verticalCenter: btnSupportLevel1.verticalCenter
                }
            }

            Row {
                id: row2

                spacing: 10

                Button {
                    id: btnSupportLevel2
                    text: qsTr("Support Level Gold")
                    width: lblSupportInfo.contentWidth * 0.5
                }

                Label {
                    id: lblLevel2
                    text: "?"
                    anchors.verticalCenter: btnSupportLevel2.verticalCenter
                }
            }

            Text {
                id: lblGooglePlay
                text: "<a href='https://play.google.com/store/apps/details?id=de.mneuroth.gnuplotviewerquick'>MobileGnuplotViewerQuick in Google Play</a>"
                Layout.topMargin: 15
            }

            Text {
                id: lblGithubPage
                text: "<a href='https://github.com/mneuroth/MobileGnuplotViewerQuick'>MobileGnuplotViewerQuick Github project page</a>"
            }

            Text {
                id: lblSupporterOfClassicVersion
                text: qsTr("You already supported the predecessor of this application !")
                visible: false //applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.topMargin: 15
            }

            Button {
                id: btnClose
                text: qsTr("Close")
                Layout.topMargin: 25
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_x:30;anchors_y:41}D{i:6;anchors_x:391}
D{i:9;anchors_x:215;anchors_y:5}D{i:1;anchors_height:200;anchors_width:200;anchors_x:108;anchors_y:91}
}
##^##*/

