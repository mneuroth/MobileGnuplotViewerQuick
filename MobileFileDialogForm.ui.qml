import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel

Page {
    id: root

    focusPolicy: Qt.StrongFocus
    focus: true

    anchors.fill: parent

    property alias btnCancel: btnCancel
    property alias btnOpen: btnOpen
    property alias btnStorage: btnStorage
    property alias btnSDCard: btnSDCard
    property alias btnHome: btnHome
    property alias btnMySd: btnMySd
    property alias btnUp: btnUp
    property alias rbnName: rbnName
    property alias rbnSize: rbnSize
    property alias rbnDate: rbnDate
    property alias txtMFDInput: txtMFDInput
    property alias lblMFDInput: lblMFDInput
    property alias lblDirectoryName: lblDirectoryName
    property alias listView: listView

    property string currentDirectory: "."
    property string currentFileName: ""
    property bool bShowFiles: true
    property bool bIsAdminModus: false
    property int iSortField: FolderListModel.Unsorted
    property bool isReverseOrder: false

    title: qsTr("Select file")

    RowLayout {
        id: columnLayout
        //width: 440
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
            id: btnMySd
            text: qsTr("MySD")
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
        anchors.left: parent.left
        anchors.leftMargin: 5
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    ListView {
        id: listView
        orientation: ListView.Vertical
        clip: true
        keyNavigationEnabled: true
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
            nameFilters: ["*"] // ["*.*","*.txt","*.log","*.cpp","*.h"]
            sortReversed: isReverseOrder
            sortField: iSortField
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
        anchors.bottom: rbnOrder.top
        anchors.bottomMargin: 5
    }

    CheckBox {
        id: chbRevertOrder
        text: qsTr("Revert order")
        checked: isReverseOrder
        onClicked: isReverseOrder = chbRevertOrder.checked
        anchors.left: chbExtendedInfos.right
        anchors.leftMargin: 15
        anchors.bottom: rbnOrder.top
        anchors.bottomMargin: 5
    }

    ButtonGroup {
        buttons: rbnOrder.children
    }

//    Frame {

    RowLayout {
        id: rbnOrder

        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.bottom: lblMFDInput.top
        anchors.bottomMargin: 5

        Label {
                text: qsTr("Sort")+":"
            }
        RadioButton {
            id: rbnUnsorted
            checked: iSortField == FolderListModel.Unsorted
            onClicked: iSortField = FolderListModel.Unsorted
            text: qsTr("Unsorted")
        }
        RadioButton {
            id: rbnName
            checked: iSortField == FolderListModel.Name
            onClicked: iSortField = FolderListModel.Name
            text: qsTr("Name")
        }
        RadioButton {
            id: rbnSize
            checked: iSortField == FolderListModel.Size
            onClicked: iSortField = FolderListModel.Size
            text: qsTr("Size")
        }
        RadioButton {
            id: rbnDate
            checked: iSortField == FolderListModel.Time
            onClicked: iSortField = FolderListModel.Time
            text: qsTr("Date")
        }
    }
//    }


    Label {
        id: lblMFDInput
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

