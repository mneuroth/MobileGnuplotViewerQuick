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
import QtQuick.Layouts 1.3

import de.mneuroth.gnuplotinvoker 1.0
//import de.mneuroth.storageaccess 1.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    width: 640
    height: 480
    title: qsTr("MobileGnuplotViewerQuick")

    property string urlPrefix: "file://"

    Settings {
        id: settings
        property string currentFile: "file:///data/data/de.mneuroth.gnuplotviewerquick/files/scripts/default.gpt"
        property bool useGnuplotBeta: false
        property int graphicsResolution: 1024
        property int graphicsFontSize: 28
        property var currentFont: null
        //property bool isFirstRun: true
    }

    Component.onDestruction: {
        settings.currentFile = homePage.currentFileUrl
        settings.useGnuplotBeta = gnuplotInvoker.useBeta
        settings.graphicsResolution = gnuplotInvoker.resolution
        settings.graphicsFontSize = gnuplotInvoker.fontSize
        settings.currentFont = homePage.textArea.font
    }

    Component.onCompleted: {
        homePage.currentFileUrl = settings.currentFile
        if( settings.currentFont !== null )
        {
            homePage.textArea.font = settings.currentFont
            outputPage.txtOutput.font = settings.currentFont
            helpPage.txtHelp.font = settings.currentFont
        }

        if(homePage.currentFileUrl.length>0)
        {
            readCurrentDoc(homePage.currentFileUrl)
        }
    }

    function getFontName() {
        if( Qt.platform.os === "android" )
        {
            return "Droid Sans Mono"
        }
        return "Courier"
    }

    function isDialogOpen() {
        return stackView.currentItem === aboutDialog || stackView.currentItem === mobileFileDialog || stackView.currentItem === settingsDialog
    }

    function checkForModified() {
        if( homePage.textArea.textDocument.modified )
        {
            // auto save document if application is closing
            saveCurrentDoc(homePage.textArea)
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

    function saveCurrentDoc(textControl) {
        var ok = applicationData.writeFileContent(homePage.currentFileUrl, textControl.text)
        if(!ok)
        {
            var sErr = qsTr("Error writing file: "+homePage.currentFileUrl+"\n")
            applicationData.logText(sErr)
            outputPage.txtOutput.text = sErr
            stackView.push(outputPage)
        }
        else
        {
            homePage.textArea.textDocument.modified = false
        }
    }

    function saveAsCurrentDoc(fullName, textControl) {
        homePage.currentFileUrl = fullName
        homePage.lblFileName.text = applicationData.getOnlyFileName(fullName)
        saveCurrentDoc(textControl)
    }

    function readCurrentDoc(url) {
        var urlFileName = buildValidUrl(url)
        homePage.currentFileUrl = urlFileName
        homePage.textArea.text = applicationData.readFileContent(urlFileName)
        homePage.textArea.textDocument.modified = false
        homePage.lblFileName.text = applicationData.getOnlyFileName(urlFileName)
    }

    function showInOutput(sContent) {
        outputPage.txtOutput.text = sContent
        stackView.pop()
        stackView.push(outputPage)
    }

    function showFileContentInOutput(sOnlyFileName) {
        var sFileName = applicationData.filesPath + sOnlyFileName
        var sContent = applicationData.readFileContent(buildValidUrl(sFileName))
        showInOutput(sContent)
    }

    function getCurrentTextRef(currentPage) {
        if(currentPage === homePage)
        {
            return homePage.textArea
        }
        else if(currentPage === outputPage)
        {
            return outputPage.txtOutput
        }
        else if(currentPage === helpPage)
        {
            return helpPage.txtHelp
        }
        return null
    }

    function getCurrentText(currentPage) {
        var s = ""
        var textControl = getCurrentTextRef(currentPage)
        if( textControl !== null )
        {
            s = textControl.text
        }
        return s
    }

    function isGraphicsPage(currentPage) {
        return currentPage === graphicsPage
    }

    onClosing: {
        // handle navigation back to home page if some other page is visible and back button is activated
        if( stackView.currentItem !== homePage )
        {
            stackView.pop()
            close.accepted = false

        }
        else
        {
            checkForModified()
            close.accepted = true
        }
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: menuButton
            text: "\u22EE"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.right: parent.right
            anchors.leftMargin: 5
            onClicked: menu.open()

            Menu {
                id: menu
                y: menuButton.height

                MenuItem {
                    text: qsTr("Send")
                    icon.source: "share.svg"
                    enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                    onTriggered: {
                        var s = getCurrentText(stackView.currentItem)
// TODO file name nach page setzen
                        applicationData.shareText(s, "gnuplot.gpt")
                    }
                }
                MenuItem {
                    text: qsTr("Send as text")
                    icon.source: "share.svg"
                    enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                    onTriggered: {
                        var s = getCurrentText(stackView.currentItem)
                        applicationData.shareSimpleText(s);
                    }
                }
                MenuItem {
                    text: qsTr("Send as PDF/PNG")
                    icon.source: "share.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            applicationData.shareSvgData(graphicsPage.svgdata)
                        }
                        else
                        {
                            var s = getCurrentText(stackView.currentItem)
                            if( s.length > 0 )
                            {
                                applicationData.shareTextAsPdf(s, true)
                            }
                        }
                    }
                }       
                MenuItem {
                    text: qsTr("View as PDF/PNG")
                    icon.source: "share.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            applicationData.shareViewSvgData(graphicsPage.svgdata)
                        }
                        else
                        {
                            var s = getCurrentText(stackView.currentItem)
                            if( s.length > 0 )
                            {
                                applicationData.shareTextAsPdf(s, false)
                            }
                        }
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Clear")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            graphicsPage.image.source = "empty.svg"
                        }
                        else
                        {
                            var textControl = getCurrentTextRef(stackView.currentItem)
                            if( textControl !== null)
                            {
                                textControl.text = ""
                            }
                            if( stackView.currentItem === homePage )
                            {
                                setScriptName(buildValidUrl(mobileFileDialog.currentDirectory+"/"+qsTr("unknown.gpt")))
                            }
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Save as")
                    enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
// TODO --> implement save image
                        }
                        else
                        {
                            var textControl = getCurrentTextRef(stackView.currentItem)
                            if( textControl !== null )
                            {
                                mobileFileDialog.textControl = textControl
                                mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                                mobileFileDialog.setSaveAsModus()
                                stackView.pop()
                                stackView.push(mobileFileDialog)
                            }
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Delete files")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        mobileFileDialog.textControl = null
                        mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                        mobileFileDialog.setDeleteModus()
                        stackView.pop()
                        stackView.push(mobileFileDialog)
                    }
                }
                MenuSeparator {}
                Menu {
                    title: qsTr("Documentation")
                    enabled: !isDialogOpen()

                    MenuItem {
                        text: qsTr("FAQ")
                        onTriggered: {
                            showFileContentInOutput("faq.txt")
                        }
                    }
                    MenuItem {
                        text: qsTr("License")
                        onTriggered: {
                            showFileContentInOutput("gnuplotviewer_license.txt")
                        }
                    }
                    MenuItem {
                        text: qsTr("Gnuplot license")
                        onTriggered: {
                            showFileContentInOutput("gnuplot_copyright")
                        }
                    }
                    MenuItem {
                        text: qsTr("Gnuplot help")
                        onTriggered: {
                            var sContent = gnuplotInvoker.run("help")
                            outputPage.txtOutput.text = sContent
                            outputPage.txtOutput.text += gnuplotInvoker.lastError
                            stackView.pop()
                            stackView.push(outputPage)
                        }
                    }
                    MenuItem {
                        text: qsTr("Gnuplot version")
                        onTriggered: {
                            var sContent = gnuplotInvoker.run("show version")
                            outputPage.txtOutput.text = sContent
                            outputPage.txtOutput.text += gnuplotInvoker.lastError
                            stackView.pop()
                            stackView.push(outputPage)
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Settings")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        settingsDialog.txtGraphicsResolution.text = gnuplotInvoker.resolution
                        settingsDialog.txtGraphicsFontSize.text = gnuplotInvoker.fontSize
                        settingsDialog.chbUseGnuplotBeta.checked = gnuplotInvoker.useBeta
                        settingsDialog.lblExampleText.font = homePage.textArea.font

                        stackView.pop()
                        stackView.push(settingsDialog)
                    }
                }
                MenuItem {
                    text: qsTr("About")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.pop()
                        stackView.push(aboutDialog)
                    }
                }
                MenuItem {
                    text: qsTr("Test")
                    onTriggered: {
                        stackView.pop()
                        stackView.push(dummyPage)
                    }
                }
            }
        }

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

    DummyPage {
        id: dummyPage
    }

    PageGraphics {
        id: graphicsPage
        objectName: "graphicsPage"

        property string svgdata: ""
    }

    PageHelp {
        id: helpPage
        objectName: "helpPage"
    }

    PageOutput {
        id: outputPage
        objectName: "outputPage"
    }

    function setScriptText(script: string)
    {
        homePage.textArea.text = script
        homePage.textArea.textDocument.modified = false
    }

    function setScriptName(name: string)
    {
        homePage.currentFileUrl = name
        homePage.lblFileName.text = applicationData.getOnlyFileName(name)
    }

    function setOutputText(txt: string)
    {
        outputPage.txtOutput.text = txt
        stackView.pop()
        stackView.push(outputPage)
    }

    Home {
        id: homePage
        objectName: "homePage"

        property string currentFileUrl: window.currentFile
    }

    AboutDialog {
        id: aboutDialog
    }

    SettingsDialog {
        id: settingsDialog
    }

    MobileFileDialog {
        id: mobileFileDialog
    }

    FontDialog {
        id: fontDialog

        //currentFont.family: "Mono"

        property var resultFcn: null

        title: qsTr("Please choose a font")

        onAccepted: {
            resultFcn(fontDialog.font)
        }
        onRejected: {
            // do nothing
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
                    stackView.pop()
                    stackView.push(graphicsPage)
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Output")
                width: parent.width
                onClicked: {
                    stackView.pop()
                    stackView.push(outputPage)
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Help")
                width: parent.width
                onClicked: {
                    stackView.pop()
                    stackView.push(helpPage)
                    drawer.close()
                }
            }
        }
    }

    GnuplotInvoker {
        id: gnuplotInvoker

        resolution: settings.graphicsResolution
        fontSize: settings.graphicsFontSize
        useBeta: settings.useGnuplotBeta
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
// TODO does not work (improve!):            window.readCurrentDoc(fileUri) --> stackView.pop() not working
            homePage.currentFileUrl = fileUri
            homePage.textArea.text = content // window.readCurrentDoc(fileUri)  //content
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)
            stackView.pop()
        }
        onOpenFileCanceled: {
//            applicationData.logText("==> onOpenFileCanceled")
            stackView.pop()
        }
        onOpenFileError: {
//            applicationData.logText("==> onOpenFileError "+message)
// TODO
            homePage.textArea.text = message
            stackView.pop()
        }
        onCreateFileReceived: {
//            applicationData.logText("==> onCreateFileReceived "+fileUri)
// TODO
            homePage.currentFileUrl = fileUri
            homePage.textArea.text += "\ncreated: "+fileUri+"\n"
            homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)
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
