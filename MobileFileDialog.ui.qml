import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.12

//Page {
Page {
    width: 450
    height: 400
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
    id: page
    anchors.fill: parent

    Column {
        id: column
        height: 62
        padding: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Button {
            id: btnStorage
            text: qsTr("Storage")
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: btnSDCard.right
            anchors.leftMargin: 6
        }

        Button {
            id: btnSDCard
            text: qsTr("SD Card")
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: btnHome.right
            anchors.leftMargin: 6
        }

        Button {
            id: btnHome
            text: qsTr("⌂")
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: btnUp.right
            anchors.leftMargin: 6
        }

        Button {
            id: btnUp
            text: qsTr("↑")
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 15
        }
    }

    Text {
        id: lblDirectoryName
        x: 16
        width: 418
        height: 15
        text: qsTr("Show current directory here")
        anchors.top: column.bottom
        anchors.topMargin: 5
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
    }

    ListView {
        id: listView
        height: 235
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.top: lblDirectoryName.bottom
        anchors.topMargin: 6


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
            nameFilters: ["*.*"]
        }

        /*Component*/ Item {
            id: fileDelegate
            Text {
                text: filePath + " / " + fileName
            }
        }

        model: folderModel
        delegate: fileDelegate
    }

    Text {
        id: lblMFDInput
        x: 16
        width: 206
        height: 15
        text: qsTr("Any input")
        anchors.top: listView.bottom
        anchors.topMargin: 8
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: 12
    }

    TextInput {
        id: txtMFDInput
        y: 323
        height: 20
        text: qsTr("Text Input")
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.left: lblMFDInput.right
        anchors.leftMargin: 6
        font.pixelSize: 12
    }

    Button {
        id: btnOpen
        x: 16
        width: 206
        height: 40
        text: qsTr("Open")
        anchors.top: lblMFDInput.bottom
        anchors.topMargin: 11
    }

    Button {
        id: btnNew
        y: 351
        text: qsTr("New")
        anchors.left: btnOpen.right
        anchors.leftMargin: 6
    }

    Button {
        id: btnCancel
        y: 351
        text: qsTr("Cancel")
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.left: btnNew.right
        anchors.leftMargin: 6
    }
} //}

/*##^##
Designer {
    D{i:1;anchors_width:450}D{i:7;anchors_width:418;anchors_x:16}
}
##^##*/

