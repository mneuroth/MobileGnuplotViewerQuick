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

MobileFileDialogForm {
    id: root

    property bool isSaveAsModus: false
    property bool isSaveACopyModus: false
    property bool isDeleteModus: false
    property bool isDirectoryModus: false
    property bool isSaveAsImage: false
    property var textControl: null

    listView {
        // https://stackoverflow.com/questions/9400002/qml-listview-selected-item-highlight-on-click
        currentIndex: -1
        focus: true
        onCurrentIndexChanged: {
            // update currently selected filename
            if( listView.currentItem !== null && listView.currentItem.isFile )
            {
                root.txtMFDInput.text = listView.currentItem.currentFileName
                root.setCurrentName(listView.currentItem.currentFileName)
            }
            else
            {
                root.txtMFDInput.text = ""
                root.setCurrentName("")
                //listView.currentItem.currentFileName("")
            }

            if( !root.isSaveAsModus )
            {
                root.btnOpen.enabled = listView.currentItem === null || listView.currentItem.isFile
            }
        }
    }

    function setAdminModus(value) {
        root.bIsAdminModus = value
    }

    function setSaveAsModus(bAsImage) {
        root.isSaveAsImage = bAsImage
        root.isSaveAsModus = true
        root.isSaveACopyModus = false
        root.isDeleteModus = false
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.lblMFDInput.text = qsTr("new file name:")
        root.txtMFDInput.text = bAsImage ? qsTr("unknown.png") : qsTr("unknown.gpt")
        root.txtMFDInput.readOnly = false
        root.btnOpen.text = qsTr("Save as")
        root.btnOpen.enabled = true
        root.btnStorage.enabled = true
    }

    function setOpenModus() {
        root.isSaveAsImage = false
        root.isSaveAsModus = false
        root.isSaveACopyModus = false
        root.isDeleteModus = false
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.lblMFDInput.text = qsTr("open name:")
        root.txtMFDInput.readOnly = true
        root.btnOpen.text = qsTr("Open")
        root.btnOpen.enabled = false
        root.btnStorage.enabled = true
    }

    function setDeleteModus() {
        root.isSaveAsImage = false
        root.isSaveAsModus = false
        root.isSaveACopyModus = false
        root.isDeleteModus = true
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.lblMFDInput.text = qsTr("current file name:")
        root.txtMFDInput.text = ""
        root.txtMFDInput.readOnly = true
        root.btnOpen.text = qsTr("Delete")
        root.btnOpen.enabled = false
        root.btnStorage.enabled = false
    }

    function setDirectory(newPath) {
        newPath = applicationData.getNormalizedPath(newPath)
        listView.model.folder = buildValidUrl(newPath)
        listView.currentIndex = -1
        listView.focus = true
        lblDirectoryName.text = newPath
        currentDirectory = newPath
    }

    function setCurrentName(name) {
        currentFileName = name
    }

    function deleteCurrentFileNow() {
        var fullPath = currentDirectory + "/" + currentFileName
        var ok = applicationData.deleteFile(fullPath)
        stackView.pop()
        if( !ok )
        {
            outputPage.txtOutput.text += qsTr("can not delete file ") + fullPath
            stackView.push(outputPage)
        }
    }

    function openCurrentFileNow() {
        var fullPath = currentDirectory + "/" + currentFileName
        window.readCurrentDoc(buildValidUrl(fullPath))
        stackView.pop()
    }

    function saveAsCurrentFileNow(fullPath) {
        if( root.isSaveAsImage )
        {
            window.saveAsImage(buildValidUrl(fullPath))
        }
        else
        {
            window.saveAsCurrentDoc(buildValidUrl(fullPath), textControl)
        }
        stackView.pop()
    }

    function navigateToDirectory(sdCardPath) {
        if( !applicationData.hasAccessToSDCardPath() )
        {
            applicationData.grantAccessToSDCardPath(window)
        }

        if( applicationData.hasAccessToSDCardPath() )
        {
            root.setDirectory(sdCardPath)
            root.setCurrentName("")
        }
    }

    Component {
        id: fileDelegate
        Rectangle {
            property string currentFileName: fileName
            property bool isFile: !fileIsDir
            height: 40
            color: "transparent"
            anchors.left: parent.left
            anchors.right: parent.right
            Keys.onPressed: {
                 if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if( fileIsDir )
                    {
                        root.setDirectory(filePath)
                        root.setCurrentName(fileName)
                        event.accepted = true
                    }
                    else
                    {
                        root.openCurrentFileNow()
                        event.accepted = true
                    }
                 }
            }
            Row {
                anchors.fill: parent
                spacing: 5

                Image {
                    id: itemIcon
                    anchors.left: parent.Left
                    height: itemLabel.height - 8
                    width: itemLabel.height - 8
                    source: fileIsDir ? "directory.svg" : "file.svg"
                }
                Label {
                    id: itemLabel
                    anchors.left: itemIcon.Right
                    anchors.right: parent.Right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    text: /*(fileIsDir ? "DIR_" : "FILE") + " | " +*/ fileName
                }
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    root.listView.currentIndex = index
                    if( fileIsDir )
                    {
                        root.setDirectory(filePath)
                        root.setCurrentName(fileName)
                    }
                }
                onDoubleClicked: {
                    root.listView.currentIndex = index
                    if( !fileIsDir )
                    {
                        root.openCurrentFileNow()
                    }
                }
            }
        }
    }

    btnOpen  {
        onClicked: {
            if( root.isDeleteModus )
            {
                root.deleteCurrentFileNow()
            }
            else if( root.isDirectoryModus )
            {
                root.selectCurrentDirectoryNow()
            }
            else if( root.isSaveAsModus )
            {
                var fullPath = currentDirectory + "/" + txtMFDInput.text
                root.saveAsCurrentFileNow(fullPath)
            }
            else
            {
                root.openCurrentFileNow()
            }
        }
    }

    btnCancel {
        onClicked: stackView.pop()
    }

    btnUp {
        onClicked: {
            // stop with moving up when home directory is reached
            if( root.bIsAdminModus || (applicationData.getNormalizedPath(currentDirectory) !== applicationData.getNormalizedPath(applicationData.homePath)) )
            {
                root.setDirectory(currentDirectory + "/..")
                root.setCurrentName("")
                root.listView.currentIndex = -1
            }
        }
    }

    btnHome {
        onClicked: {
            root.setDirectory(applicationData.homePath)
            root.setCurrentName("")
            root.listView.currentIndex = -1
        }
    }

    Menu {
        id: menuSDCard
        Repeater {
                model: applicationData !== null ? applicationData.getSDCardPaths() : []
                MenuItem {
                    text: modelData
                    onTriggered: {
                        root.navigateToDirectory(modelData)
                    }
                }
        }
    }

    btnSDCard {
        onClicked: {
            menuSDCard.x = btnSDCard.x
            menuSDCard.y = btnSDCard.height
            menuSDCard.open()
        }
    }

    btnStorage {
        visible: applicationData !== null ? applicationData.isShareSupported : false
        onClicked: {
            if( root.isSaveAsModus )
            {
                storageAccess.createFile(root.txtMFDInput.text)
            }
            else
            {
                storageAccess.openFile()
            }
        }
    }
}
