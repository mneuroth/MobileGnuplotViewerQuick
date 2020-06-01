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
import Qt.labs.settings 1.0

import de.mneuroth.gnuplotinvoker 1.0
//import de.mneuroth.storageaccess 1.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

    property string urlPrefix: "file://"

    Settings {
        id: settings
        property string currentFile: ""
    }

    Component.onDestruction: {
        settings.currentFile = homePage.currentFileUrl
    }

    Component.onCompleted: {
        applicationData.logText("### OnCompleted reading: "+settings.currentFile)
        homePage.currentFileUrl = settings.currentFile
        if(homePage.currentFileUrl.length>0)
        {
            readCurrentDoc(homePage.currentFileUrl)
        }
    }

    function checkForModified() {
        if( homePage.textArea.textDocument.modified )
        {
            // auto save document if application is closing
            saveCurrentDoc()
        }
    }

    function buildValidUrl(path) {
        // ignore call, if we already have a file:// url
        if( path.startsWith(urlPrefix) )
        {
            return path;
        }
        // ignore call, if we already have a content:// url (android storage framework)
        if( path.startsWith("content://") )
        {
            return path;
        }

        var sAdd = path.startsWith("/") ? "" : "/"
        var sUrl = urlPrefix + sAdd + path
        return sUrl
    }

    function saveCurrentDoc() {
        applicationData.logText("SAVE "+homePage.currentFileUrl)
        var ok = applicationData.writeFileContent(homePage.currentFileUrl, homePage.textArea.text)
        if(!ok)
        {
            applicationData.logText("Error writing file... "+homePage.currentFileUrl)
        }
        homePage.textArea.textDocument.modified = false
    }

    function readCurrentDoc(url) {
        var urlFileName = buildValidUrl(url)
        homePage.currentFileUrl = urlFileName
        homePage.textArea.text = applicationData.readFileContent(urlFileName)
        homePage.textArea.textDocument.modified = false
        homePage.lblFileName.text = urlFileName
    }

    onClosing: {
        checkForModified()
        //close.accepted = true
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2261"  // original: "\u2630" for second entry, does not work on Android
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }
    }

    Page1Form {
        id: graphicsPage
        objectName: "graphicsPage"

        imageMouseArea {
            // see: photosurface.qml
            onWheel: {
                if (wheel.modifiers & Qt.ControlModifier) {
                    image.rotation += wheel.angleDelta.y / 120 * 5;
                    if (Math.abs(photoFrame.rotation) < 4)
                        image.rotation = 0;
                } else {
                    image.rotation += wheel.angleDelta.x / 120;
                    if (Math.abs(image.rotation) < 0.6)
                        image.rotation = 0;
                    var scaleBefore = image.scale;
                    image.scale += image.scale * wheel.angleDelta.y / 120 / 10;
                }
            }
            onDoubleClicked: {
                // set to default with double click
                image.scale = 1.0
                image.x = 0
                image.y = 0
            }
        }
    }

    Page2Form {
        id: helpPage
        objectName: "helpPage"
    }

    function setScriptText(script: string)
    {
        homePage.textArea.text = script
        homePage.textArea.textDocument.modified = false
    }

    function setScriptName(name: string)
    {
        homePage.currentFileUrl = name
        homePage.lblFileName.text = name
    }

    HomeForm {
        id: homePage
        objectName: "homePage"

        property string currentFileUrl: window.currentFile

        textArea {
            onTextChanged: {
                // set modified flag for autosave of document
                textArea.textDocument.modified = true
            }
        }

        btnOpen  {
            onClicked:  {
                //fileDialog.open()
                //mobileFileDialog.open()
                mobileFileDialog.btnNew.visible = true
                if( mobileFileDialog.currentDirectory == "" )
                {
                    mobileFileDialog.currentDirectory = applicationData.homePath
                }
                mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                stackView.push(mobileFileDialog)
            }
        }

        btnSave {
            onClicked: {
                saveCurrentDoc()
            }
        }

        btnSaveAs {
            onClicked: {
                if( !applicationData.shareText(homePage.textArea.text) )
                {
                    homePage.textArea.text = "SHARE result = false\n"
                }
                else
                {
                    homePage.textArea.text = "SHARE result = TRUE\n"
                }
            }
        }

        btnRun {
            onClicked: {
                var sData = gnuplotInvoker.run(homePage.textArea.text)
                // see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
                graphicsPage.image.source = "data:image/svg+xml;utf8," + sData
                stackView.push(graphicsPage)
            }
        }

        btnGraphics {
            onClicked: {
                stackView.push(graphicsPage)
            }
        }

        btnExit {
            onClicked: {
                //onClicked: window.close() //Qt.quit()
                applicationData.test()
            }
        }

        btnClear {
            onClicked: {
                homePage.textArea.text = ""
                homePage.lblFileName.text = "unknown"
            }
        }
    }

    MobileFileDialog {
        id: mobileFileDialog

        listView {
            // https://stackoverflow.com/questions/9400002/qml-listview-selected-item-highlight-on-click
            currentIndex: -1
            focus: true
            onCurrentIndexChanged: {
                console.log("current changed ! ")
                console.log(listView.currentIndex)
                if( listView.currentItem ) {
// TODO --> nur bei files nicht bei directories !
                    mobileFileDialog.setCurrentName(listView.currentItem.currentFileName)
                }
            }
        }

        function setDirectory(newPath) {
            newPath = applicationData.normalizePath(newPath)
            listView.model.folder = buildValidUrl(newPath)
            listView.currentIndex = -1
            listView.focus = true
            lblDirectoryName.text = newPath
            currentDirectory = newPath
        }

        function setCurrentName(name) {
            txtMFDInput.text = name
            currentFileName = name
        }

        function openCurrentFileNow() {
            var fullPath = currentDirectory + "/" + currentFileName
            window.readCurrentDoc(buildValidUrl(fullPath))
            stackView.pop()
        }

        Component {
            id: fileDelegate
            Rectangle {
                property string currentFileName: fileName
                height: 40
                color: "transparent"
                anchors.left: parent.left
                anchors.right: parent.right
                Keys.onPressed: {
                     if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
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
                Label {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: (fileIsDir ? "DIR_" : "FILE") + /*filePath +*/ " | " + fileName
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
                openCurrentFileNow()
            }
        }

        btnCancel {
            onClicked: stackView.pop()
        }

        btnUp {
            onClicked: {
                mobileFileDialog.setDirectory(currentDirectory + "/..")
                mobileFileDialog.setCurrentName("")
            }
        }

        btnHome {
            onClicked: {
                mobileFileDialog.setDirectory(applicationData.homePath)
                mobileFileDialog.setCurrentName("")
            }
        }

        btnSDCard {
            onClicked: {
                if( !applicationData.hasAccessToSDCardPath() )
                {
                    applicationData.grantAccessToSDCardPath(window)
                }

                if( applicationData.hasAccessToSDCardPath() )
                {
                    mobileFileDialog.setDirectory(applicationData.sdCardPath)
                    mobileFileDialog.setCurrentName("")
                }
            }
        }

        btnStorage {
            onClicked: {
                //fileDialog.open()
                storageAccess.openFile()
            }
        }
    }

    FileDialog {
        id: fileDialog
        visible: false
        modality: Qt.WindowModal
        title: qsTr("Choose a file")
        folder: "." //StandardPaths.writableLocation(StandardPaths.DocumentsLocation) //"c:\sr"
        selectExisting: true
        selectMultiple: false
        selectFolder: false
        //nameFilters: ["Image files (*.png *.jpg)", "All files (*)"]
        //selectedNameFilter: "All files (*)"
        sidebarVisible: false
        onAccepted: {
              console.log("Accepted: " + fileUrls)
              //homePage.textArea.text = "# Hello World !\nplot sin(x)"

// TODO: https://www.volkerkrause.eu/2019/02/16/qt-open-files-on-android.html
// https://stackoverflow.com/questions/58715547/how-to-open-a-file-in-android-with-qt-having-the-content-uri

              window.readCurrentDoc(fileUrls[0])
              stackView.pop()

              //if (fileDialogOpenFiles.checked)
              //    for (var i = 0; i < fileUrls.length; ++i)
              //        Qt.openUrlExternally(fileUrls[i])
        }
        onRejected: { console.log("Rejected") }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Graphics")
                width: parent.width
                onClicked: {
                    stackView.push(graphicsPage)
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Help")
                width: parent.width
                onClicked: {
                    stackView.push(helpPage)
                    drawer.close()
                }
            }
        }
    }

    GnuplotInvoker {
        id: gnuplotInvoker
    }

//    StorageAccess {
//        id: storageAccess
//    }

    Connections {
        target: applicationData

        onSendDummyData: {
            console.log("========> Dummy Data !!! "+txt+" "+value)
        }
    }

    Connections {
        target: storageAccess

        onOpenFileContentReceived: {
            applicationData.logText("==> onOpenFileContentReceived "+fileUri+" "+decodedFileUri)
// TODO does not work (improve!):            window.readCurrentDoc(fileUri)
            homePage.currentFileUrl = fileUri
            homePage.textArea.text = content // window.readCurrentDoc(fileUri)  //content
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = fileUri
            stackView.pop()
        }
        onOpenFileCanceled: {
            applicationData.logText("==> onOpenFileCanceled")
            stackView.pop()
        }
        onOpenFileError: {
            applicationData.logText("==> onOpenFileError "+message)
// TODO
            homePage.textArea.text = message
            stackView.pop()
        }
        onCreateFileReceived: {
            applicationData.logText("==> onCreateFileReceived "+fileUri)
// TODO
            homePage.textArea.text += "\ncreated: "+fileUri+"\n"
            homePage.lblFileName.text = fileUri
            stackView.pop()
        }
    }

    StackView {
        id: stackView
        initialItem: homePage
        anchors.fill: parent
        width: parent.width
        height: parent.height
    }
}
