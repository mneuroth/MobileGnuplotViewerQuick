

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
import Qt.labs.folderlistmodel 2.12
import QtQuick.Layouts 1.3

Page {
    property alias btnCancel: btnCancel
    property alias btnNew: btnNew
    property alias btnOpen: btnOpen
    property alias txtMFDInput: txtMFDInput
    property alias lblMFDInput: lblMFDInput
    property alias listView: listView
    property alias lblDirectoryName: lblDirectoryName
    property alias btnStorage: btnStorage
    property alias btnSDCard: btnSDCard
    property alias btnHome: btnHome
    property alias btnUp: btnUp

    property string currentDirectory: ""
    property string currentFileName: ""

    width: 450
    height: 400
    id: page
    anchors.fill: parent

    RowLayout {
        id: columnLayout
        width: 440
        height: 40
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5

        Button {
            id: btnUp
            height: 40
            text: qsTr("↑")
            Layout.rightMargin: 0
            Layout.leftMargin: 0
            Layout.bottomMargin: 0
            Layout.topMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnHome
            text: qsTr("⌂")
            Layout.rightMargin: 0
            Layout.leftMargin: 0
            Layout.bottomMargin: 0
            Layout.topMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnSDCard
            text: qsTr("SD Card")
            Layout.rowSpan: 1
            Layout.columnSpan: 1
            Layout.rightMargin: 0
            Layout.leftMargin: 0
            Layout.bottomMargin: 0
            Layout.topMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnStorage
            text: qsTr("Storage")
            Layout.rightMargin: 0
            Layout.leftMargin: 0
            Layout.bottomMargin: 0
            Layout.topMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Label {
        id: lblDirectoryName
        x: 16
        width: 418
        height: 40
        text: qsTr("Show current directory here")
        anchors.top: columnLayout.bottom
        anchors.topMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        //font.pixelSize: 12
    }

    ListView {
        id: listView
        anchors.bottom: lblMFDInput.top
        anchors.bottomMargin: 6
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: lblDirectoryName.bottom
        anchors.topMargin: 5


        /*
        model: ListModel {
            ListElement {
                name: "Grey"
                colorCode: "grey"
            }

            ListElement {
                name: "Red"
                colorCode: "red"
            }

            ListElement {
                name: "Blue"
                colorCode: "blue"
            }

            ListElement {
                name: "Green"
                colorCode: "green"
            }
        }
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
            }
        }
        */
        FolderListModel {
            id: folderModel
            nameFilters: ["*"]
        }

        highlight: Rectangle {
            color: "lightsteelblue"
            radius: 3
        }
        focus: true
        model: folderModel
        delegate: fileDelegate
    }

    Label {
        id: lblMFDInput
        width: 221
        height: 40
        text: qsTr("Any input")
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: gridLayout.top
        anchors.bottomMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        //font.pixelSize: 12
    }

    TextInput {
        id: txtMFDInput
        y: 323
        height: 40
        text: qsTr("Text Input")
        anchors.bottom: gridLayout.top
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: lblMFDInput.right
        anchors.leftMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        //font.pixelSize: 12
    }

    GridLayout {
        id: gridLayout
        height: 40
        rows: 1
        columns: 4
        columnSpacing: 5
        rowSpacing: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5

        Button {
            id: btnOpen
            width: 213
            text: qsTr("Open")
            Layout.fillWidth: true
            Layout.column: 0
            Layout.fillHeight: true
            //Layout.fillWidth: true
            Layout.columnSpan: 2
        }
/*
        Rectangle {
            id: newRect
            color: "blue"
            visible: !btnNew.visible
            Layout.column: 2
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / parent.columns
        }
*/
        Button {
            id: btnNew
            width: 106
            text: qsTr("New")
            Layout.fillWidth: true
            Layout.column: 2
            Layout.fillHeight: true
            //Layout.fillWidth: true
        }

        Button {
            id: btnCancel
            width: 106
            text: qsTr("Cancel")
            Layout.fillWidth: true
            Layout.column: 3
            Layout.fillHeight: true
            //Layout.fillWidth: true
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.8999999761581421}D{i:1;anchors_width:450}D{i:7;anchors_height:284}
D{i:10;anchors_x:16}D{i:11;anchors_height:15}D{i:13;anchors_height:37;anchors_width:100}
D{i:12;anchors_y:323}
}
##^##*/

