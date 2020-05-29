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

import de.mneuroth.gnuplotinvoker 1.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

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
        }
    }

    Page2Form {
        id: helpPage
        objectName: "helpPage"
    }

    HomeForm {
        id: homePage
        objectName: "homePage"

        property string currentFileUrl: ""

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
                //homePage.textArea.text += "INIT:" + mobileFileDialog.currentDirectory + "\n"
                stackView.push(mobileFileDialog)
            }
        }

        btnSave {
            onClicked: {
                applicationData.writeFileContent(homePage.currentFileUrl, homePage.textArea.text)
            }
        }

        btnRun {
            onClicked: {
                var s = gnuplotInvoker.run(homePage.textArea.text)
                // see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
                graphicsPage.image.source = "data:image/svg+xml;utf8," + s
                stackView.push(graphicsPage)
            }
        }

        btnGraphics {
            onClicked: {
                console.log("graphics size:")
                console.log(graphicsPage.image.width)
                console.log(graphicsPage.image.height)
                stackView.push(graphicsPage)
            }
        }

        btnExit {
            onClicked: {
                onClicked: Qt.quit()
            }
        }

        btnClear {
            onClicked: {
                homePage.textArea.text = ""
            }
        }
    }

    MobileFileDialog {
        id: mobileFileDialog

        property string urlPrefix: "file://"

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

            //homePage.textArea.text += "count= " + listView.model.count + "\n"
            //homePage.textArea.text += "root= " + listView.model.rootFolder + "\n"
            //homePage.textArea.text += "folder= " + listView.model.folder + "\n"
            //homePage.textArea.text += "parentFolder= " + listView.model.parentFolder + "\n"
            //homePage.textArea.text += "showFiles= " + listView.model.showFiles + "\n"
            //homePage.textArea.text += "status= " + listView.model.status
            //homePage.textArea.text += applicationData.dumpDirectoryContent(newPath)

        }

        function setCurrentName(name) {
            txtMFDInput.text = name
            currentFileName = name
        }

        function buildValidUrl(path) {
            var sAdd = path.startsWith("/") ? "" : "/"
            var s = urlPrefix + sAdd + path
            console.log("URL=" + s)
            return s
        }

        function openCurrentFileNow() {
            var fullPath = currentDirectory + "/" + currentFileName
            homePage.currentFileUrl = buildValidUrl(fullPath)
            homePage.textArea.text = applicationData.readFileContent(buildValidUrl(fullPath))
            homePage.lblFileName.text = currentFileName
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
                        console.log("ENTER PRESSED "+filePath+" "+parent+" "+parent.parent+" "+parent.parent.parent)
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
                //homePage.textArea.text += applicationData.homePath + "\n"
            }
        }

        btnSDCard {
            onClicked: {
                if( !applicationData.HasAccessToSDCardPath() )
                {
                    applicationData.GrantAccessToSDCardPath(window)
                }

                if( applicationData.HasAccessToSDCardPath() )
                {
                    mobileFileDialog.setDirectory(applicationData.sdCardPath)
                    mobileFileDialog.setCurrentName("")
                    //homePage.textArea.text += applicationData.sdCardPath + "\n"
                }
            }
        }

        btnStorage {
            onClicked: {
                fileDialog.open()
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

              homePage.currentFileUrl = fileUrls[0]
              homePage.textArea.text = applicationData.readFileContent(fileUrls[0])
              homePage.lblFileName.text = fileUrls[0]
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

    StackView {
        id: stackView
        initialItem: homePage
        anchors.fill: parent
        width: parent.width
        height: parent.height
    }
}
