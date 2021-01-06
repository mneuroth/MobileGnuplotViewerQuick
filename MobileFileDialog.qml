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
import QtQuick.Dialogs 1.2

MobileFileDialogForm {
    property bool isSaveAsModus: false
    property bool isDeleteModus: false
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
                mobileFileDialog.txtMFDInput.text = listView.currentItem.currentFileName
                mobileFileDialog.setCurrentName(listView.currentItem.currentFileName)
            }
            else
            {
                mobileFileDialog.txtMFDInput.text = ""
                mobileFileDialog.setCurrentName("")
                //listView.currentItem.currentFileName("")
            }

            if( !mobileFileDialog.isSaveAsModus )
            {
                mobileFileDialog.btnOpen.enabled = listView.currentItem === null || listView.currentItem.isFile
            }
        }
    }

    function setSaveAsModus(bAsImage) {
        mobileFileDialog.isSaveAsImage = bAsImage
        mobileFileDialog.isSaveAsModus = true
        mobileFileDialog.isDeleteModus = false
        mobileFileDialog.lblMFDInput.text = qsTr("new file name:")
        mobileFileDialog.txtMFDInput.text = bAsImage ? qsTr("unknown.png") : qsTr("unknown.gpt")
        mobileFileDialog.txtMFDInput.readOnly = false
        mobileFileDialog.btnOpen.text = qsTr("Save as")
        mobileFileDialog.btnOpen.enabled = true
    }

    function setOpenModus() {
        mobileFileDialog.isSaveAsImage = false
        mobileFileDialog.isSaveAsModus = false
        mobileFileDialog.isDeleteModus = false
        mobileFileDialog.lblMFDInput.text = qsTr("open name:")
        mobileFileDialog.txtMFDInput.readOnly = true
        mobileFileDialog.btnOpen.text = qsTr("Open")
        mobileFileDialog.btnOpen.enabled = false
    }

    function setDeleteModus() {
        mobileFileDialog.isSaveAsImage = false
        mobileFileDialog.isSaveAsModus = false
        mobileFileDialog.isDeleteModus = true
        mobileFileDialog.lblMFDInput.text = qsTr("current file name:")
        mobileFileDialog.txtMFDInput.text = ""
        mobileFileDialog.txtMFDInput.readOnly = true
        mobileFileDialog.btnOpen.text = qsTr("Delete")
        mobileFileDialog.btnOpen.enabled = false
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
        if( mobileFileDialog.isSaveAsImage )
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
            mobileFileDialog.setDirectory(sdCardPath)
            mobileFileDialog.setCurrentName("")
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
                        mobileFileDialog.setDirectory(filePath)
                        mobileFileDialog.setCurrentName(fileName)
                        event.accepted = true
                    }
                    else
                    {
                        mobileFileDialog.openCurrentFileNow()
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
                    mobileFileDialog.listView.currentIndex = index
                    if( fileIsDir )
                    {
                        mobileFileDialog.setDirectory(filePath)
                        mobileFileDialog.setCurrentName(fileName)
                    }
                }
                onDoubleClicked: {
                    mobileFileDialog.listView.currentIndex = index
                    if( !fileIsDir )
                    {
                        mobileFileDialog.openCurrentFileNow()
                    }
                }
            }
        }
    }

    btnOpen  {
        onClicked: {
            if( mobileFileDialog.isDeleteModus )
            {
                mobileFileDialog.deleteCurrentFileNow()
            }
            else
            {
                if( mobileFileDialog.isSaveAsModus )
                {
                    var fullPath = currentDirectory + "/" + txtMFDInput.text
                    mobileFileDialog.saveAsCurrentFileNow(fullPath)
                }
                else
                {
                    mobileFileDialog.openCurrentFileNow()
                }
            }

        }
    }

    btnCancel {
        onClicked: stackView.pop()
    }

    btnUp {
        onClicked: {
            // stop with moving up when home directory is reached
            if( applicationData.getNormalizedPath(currentDirectory) !== applicationData.getNormalizedPath(applicationData.homePath) )
            {
                mobileFileDialog.setDirectory(currentDirectory + "/..")
                mobileFileDialog.setCurrentName("")
                mobileFileDialog.listView.currentIndex = -1
            }
        }
    }

    btnHome {
        onClicked: {
            mobileFileDialog.setDirectory(applicationData.homePath)
            mobileFileDialog.setCurrentName("")
            mobileFileDialog.listView.currentIndex = -1
        }
    }

    Menu {
        id: menuSDCard
        Repeater {
                model: applicationData !== null ? applicationData.getSDCardPaths() : []
                MenuItem {
                    text: modelData
                    onTriggered: {
                        mobileFileDialog.navigateToDirectory(modelData)
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
        visible: applicationData.isShareSupported
        onClicked: {
            if( mobileFileDialog.isSaveAsModus )
            {
                storageAccess.createFile(mobileFileDialog.txtMFDInput.text)
            }
            else
            {
                storageAccess.openFile()
            }
        }
    }
}
