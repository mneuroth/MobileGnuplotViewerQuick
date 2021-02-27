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
import Qt.labs.folderlistmodel 2.1
import QtQuick.Layouts 1.3

Page {
    id: root

    focusPolicy: Qt.StrongFocus
    focus: true

    anchors.fill: parent

    property alias btnCancel: btnCancel
    property alias btnOpen: btnOpen
    property alias txtMFDInput: txtMFDInput
    property alias lblMFDInput: lblMFDInput
    property alias listView: listView
    property alias lblDirectoryName: lblDirectoryName
    property alias btnStorage: btnStorage
    property alias btnSDCard: btnSDCard
    property alias btnHome: btnHome
    property alias btnUp: btnUp

    property string currentDirectory: "."
    property string currentFileName: ""
    property bool bShowFiles: true
    property bool bIsAdminModus: applicationData!==null ? applicationData.isAdmin : false

    title: qsTr("Select file")

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
        text: qsTr("Show current directory here")
        anchors.top: columnLayout.bottom
        anchors.topMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    ListView {
        id: listView
        orientation: ListView.Vertical
        clip: true
        anchors.bottom: chbExtendedInfos.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: lblDirectoryName.bottom
        anchors.topMargin: 10

        FolderListModel {
            id: folderModel
            showFiles: bShowFiles
            showHidden: bIsAdminModus
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

    CheckBox {
        id: chbExtendedInfos
        text: qsTr("Show date and size")
        checked: isExtendedInfos
        onClicked: isExtendedInfos = chbExtendedInfos.checked
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: lblMFDInput.top
        anchors.bottomMargin: 5
    }

    Label {
        id: lblMFDInput
        //width: 221
        height: 40
        text: qsTr("Any input")
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: btnOpen.top
        anchors.bottomMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        color: "lightyellow"
        height: txtMFDInput.height
        width: txtMFDInput.width
        visible: txtMFDInput.visible
        x: txtMFDInput.x
        y: txtMFDInput.y
    }

    TextInput {
        id: txtMFDInput
        height: lblMFDInput.height
        text: ""
        anchors.bottom: btnCancel.top
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: lblMFDInput.right
        anchors.leftMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    Button {
        id: btnOpen
        enabled: false
        text: qsTr("Open")
        width: btnUp.width + btnUp.width / 2
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }

    Button {
        id: btnCancel
        width: btnStorage.width + btnStorage.width / 2
        text: qsTr("Cancel")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.8999999761581421}D{i:1;anchors_width:450}D{i:7;anchors_height:284}
D{i:10;anchors_x:16}D{i:11;anchors_height:15}D{i:12;anchors_y:323}D{i:13;anchors_height:37;anchors_width:100}
}
##^##*/

