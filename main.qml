/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

import QtQuick 2.9
import QtQuick.Controls 2.2
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

    property string emptyString: "      "
    property string urlPrefix: "file://"   
    property bool isAndroid: applicationData !== null ? applicationData.isAndroid : false
    property bool isShareSupported: applicationData !== null ? applicationData.isShareSupported : false
    property bool isAppStoreSupported: applicationData !== null ? applicationData.isAppStoreSupported : false

    Component.onDestruction: {
        settings.currentFile = homePage.currentFileUrl
        settings.useGnuplotBeta = gnuplotInvoker.useBeta
        settings.graphicsResolution = gnuplotInvoker.resolution
        settings.graphicsFontSize = gnuplotInvoker.fontSize
        settings.invokeCount = gnuplotInvoker.invokeCount
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

    // **********************************************************************
    // *** some helper functions for the application
    // **********************************************************************

    function clearCurrentText() {
        var textControl = getCurrentTextRef(stackView.currentItem)
        if( textControl !== null)
        {
            textControl.text = emptyString
            textControl.textDocument.modified = false
        }
        if( stackView.currentItem === homePage )
        {
            setScriptName(buildValidUrl(mobileFileDialog.currentDirectory+"/"+qsTr("unknown.gpt")))
        }
    }

    function showInfoDialog(msg, title) {
        infoDialog.text = msg
        if( title !== undefined ) {
            infoDialog.title = title
        }
        infoDialog.open()
    }

    function showThankYouDialog(supportLevel) {
        showInfoDialog(qsTr("Thank you for supporting the development of this application !"), qsTr("Thank you !"))
    }

    function getFontName() {
        if( Qt.platform.os === "android" )
        {
            return "Droid Sans Mono"
        }
        return "Courier"
    }

    function isCurrentUserSupporter() {
        return settings.supportLevel>=0 || (applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false)
    }

    function isDialogOpen() {
        var otherChecks = false
        if( isAppStoreSupported )
        {
            otherChecks = (stackView.currentItem === supportDialog)
        }

        return stackView.currentItem === aboutDialog ||
               stackView.currentItem === mobileFileDialog ||
               stackView.currentItem === settingsDialog ||
               otherChecks
    }

    function checkForModified() {
        if( homePage.textArea.textDocument.modified )
        {
            // auto save document if application is closing
            saveCurrentDoc(homePage.textArea)            
        }
    }

    function checkForUserNotification() {
        if( isAppStoreSupported && settings.supportLevel<0 && gnuplotInvoker.invokeCount % 51 === 50 )
        {
            myUserNotificationDialog.open()
        }
    }

    function buildValidUrl(path) {
        // ignore call, if we already have a file:// url
        if( path.startsWith(urlPrefix) )
        {
            return path
        }
        // ignore call, if we try to access resouces from qrc --> path starting with :
        if( path.startsWith(":") )
        {
            return path
        }
        // ignore call, if we already have a content:// url (android storage framework)
        if( path.startsWith("content://") )
        {
            return path
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
            homePage.removeModifiedFlag()
        }
    }

    function saveCurrentGraptics(fileName) {
        applicationData.saveDataAsPngImage(fileName,graphicsPage.svgdata)
    }

    function saveAsImage(fullName) {
        saveCurrentGraptics(fullName)
    }

    function saveAsCurrentDoc(fullName, textControl) {
        homePage.currentFileUrl = fullName
        homePage.lblFileName.text = applicationData.getOnlyFileName(fullName)
        saveCurrentDoc(textControl)
    }

    function readCurrentDoc(url) {
        // first save possible modified current gnuplot script
        checkForModified()
        // then read new document
        var urlFileName = buildValidUrl(url)
        homePage.currentFileUrl = urlFileName        
        homePage.textArea.text = applicationData.readFileContent(urlFileName)
        homePage.textArea.textDocument.modified = false
        homePage.lblFileName.text = applicationData.getOnlyFileName(urlFileName)
        // update the current directory after starting the application...
        mobileFileDialog.currentDirectory = applicationData.getLocalPathWithoutFileName(urlFileName)
    }

    function showInOutput(sContent, bShowOutputPage) {
        outputPage.txtOutput.text += "\n" + sContent
        if(bShowOutputPage) {
            stackView.pop()
            stackView.push(outputPage)
        }
    }

    function jumpToEndOfOutput() {
        var bReadOnly = outputPage.txtOutput.text.readOnly;
        outputPage.forceActiveFocus()
        outputPage.txtOutput.forceActiveFocus()
        outputPage.txtOutput.text.readOnly = false
        outputPage.txtOutput.text.focus = true
        outputPage.txtOutput.text.cursorPosition = outputPage.txtOutput.text.length
        outputPage.txtOutput.text.readOnly = bReadOnly
    }

    function showFileContentInOutput(sOnlyFileName) {
        var sFileName = applicationData.filesPath + sOnlyFileName
        var sContent = applicationData.readFileContent(buildValidUrl(sFileName))
        showInOutput(sContent, true)
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

    function getTempFileNameForCurrent(currentPage) {
        if(currentPage === homePage)
        {
            return "gnuplot.gpt"
        }
        else if(currentPage === outputPage)
        {
            return "output.txt"
        }
        else if(currentPage === helpPage)
        {
            return "help.txt"
        }
        return "unknown.txt"
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

    function initDone()
    {
        homePage.isInInit = false
    }

    function setScriptText(script/*: string*/)
    {
        homePage.textArea.text = script
        homePage.textArea.textDocument.modified = false
    }

    function setScriptName(name/*: string*/)
    {
        homePage.currentFileUrl = name
        homePage.lblFileName.text = applicationData.getOnlyFileName(name)
    }

    function setOutputText(txt/*: string*/)
    {
        outputPage.txtOutput.text = txt
        stackView.pop()
        stackView.push(outputPage)
    }

    // **********************************************************************
    // *** some gui items for the application
    // **********************************************************************

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: menuButton
            //text: "\u22EE"
            icon.source: "menu.svg"
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
                    visible: isShareSupported
                    height: isShareSupported ? aboutMenuItem.height : 0
                    onTriggered: {
                        var s = getCurrentText(stackView.currentItem)
                        var tempFileName = getTempFileNameForCurrent(stackView.currentItem)
                        applicationData.shareText(tempFileName, s)
                    }
                }
                MenuItem {
                    id: shareText
                    text: qsTr("Send as text")
                    icon.source: "share.svg"
                    enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                    visible: isShareSupported
                    height: isShareSupported ? aboutMenuItem.height : 0
                    onTriggered: {
                        var s = getCurrentText(stackView.currentItem)
                        applicationData.shareSimpleText(s);
                    }
                }
                MenuItem {
                    id: sharePng
                    text: qsTr("Send as PDF/PNG")
                    icon.source: "share.svg"
                    enabled: !isDialogOpen() && isCurrentUserSupporter()
                    visible: isShareSupported
                    height: isShareSupported ? aboutMenuItem.height : 0
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            var ok = applicationData.shareSvgData(graphicsPage.svgdata)
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
                    visible: isShareSupported
                    height: isShareSupported ? aboutMenuItem.height : 0
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            var ok = applicationData.shareViewSvgData(graphicsPage.svgdata)
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
                MenuSeparator {
                    visible: isShareSupported
                    height: isShareSupported ? menuSeparator.height : 0
                }
                MenuItem {
                    text: qsTr("Writable")
                    icon.source: "edit.svg"
                    checkable: true
                    checked: writableIcon.checked
                    enabled: !isDialogOpen() && (stackView.currentItem === homePage || stackView.currentItem === outputPage || stackView.currentItem === helpPage)
                    onTriggered: {
                        writableIcon.toggle()
                    }
                }
                MenuItem {
                    text: qsTr("Clear/New")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            graphicsPage.image.source = "empty.svg"
                        }
                        else
                        {
                            var textControl = getCurrentTextRef(stackView.currentItem)
                            if( textControl.textDocument.modified )
                            {
                                askForClearDialog.open()
                            }
                            else
                            {
                                clearCurrentText()
                            }
                        }
                    }
                }
                /*
                MenuItem {
                    text: qsTr("set graphics")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        graphicsPage.image.source = applicationData.isWASM ? "file:///temp.svg" : "file:///c:/tmp/temp.svg"
                    }
                }
                MenuItem {
                    text: qsTr("Open local")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        mobileFileDialog.setOpenModus()
                        if( mobileFileDialog.currentDirectory == "" )
                        {
                            mobileFileDialog.currentDirectory = applicationData.homePath
                        }
                        mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                        stackView.pop()
                        stackView.push(mobileFileDialog)
                    }
                }
                */
                MenuItem {
                    text: qsTr("Save as")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                            mobileFileDialog.setSaveAsModus(true)
                            stackView.pop()
                            stackView.push(mobileFileDialog)
                        }
                        else
                        {
                            var textControl = getCurrentTextRef(stackView.currentItem)
                            if( textControl !== null )
                            {
                                mobileFileDialog.textControl = textControl
                                mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                                mobileFileDialog.setSaveAsModus(false)
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
                MenuSeparator {
                    id: menuSeparator
                }
                MenuItem {
                    id: menuUndo
                    icon.source: "back-arrow.svg"
                    text: qsTr("Undo")
                    enabled: writableIcon.checked && ((stackView.currentItem === homePage && homePage.textArea.canUndo) || (stackView.currentItem === outputPage && outputPage.txtOutput.canUndo) || (stackView.currentItem === helpPage && helpPage.txtHelp.canUndo))
                    onTriggered: {
                        var textControl = getCurrentTextRef(stackView.currentItem)
                        if( textControl !== null )
                        {
                            textControl.undo()
                        }
                    }
                }
                MenuItem {
                    id: menuRedo
                    icon.source: "redo-arrow.svg"
                    text: qsTr("Redo")
                    enabled: writableIcon.checked && ((stackView.currentItem === homePage && homePage.textArea.canRedo) || (stackView.currentItem === outputPage && outputPage.txtOutput.canRedo) || (stackView.currentItem === helpPage && helpPage.txtHelp.canRedo))
                    onTriggered: {
                        var textControl = getCurrentTextRef(stackView.currentItem)
                        if( textControl !== null )
                        {
                            textControl.redo()
                        }
                    }
                }
                MenuSeparator {
                    id: menuSeparator2
                }
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
                            outputPage.txtOutput.text += sContent
                            outputPage.txtOutput.text += gnuplotInvoker.lastError
                            stackView.pop()
                            stackView.push(outputPage)
                        }
                    }
                    MenuItem {
                        text: qsTr("Gnuplot version")
                        onTriggered: {
                            var sContent = gnuplotInvoker.run("show version")
                            outputPage.txtOutput.text += sContent
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
                        settingsDialog.chbUseToolBar.checked = settings.useToolBar
                        settingsDialog.chbUseLocalFiledialog.checked = applicationData.isUseLocalFileDialog
                        settingsDialog.lblExampleText.font = homePage.textArea.font

                        stackView.pop()
                        stackView.push(settingsDialog)
                    }
                }
                MenuItem {
                    id: supportMenuItem
                    text: qsTr("Support")
                    enabled: !isDialogOpen() && isAppStoreSupported
                    visible: isAppStoreSupported
                    height: isAppStoreSupported ? aboutMenuItem.height : 0
                    onTriggered: {
                        stackView.pop()
                        stackView.push(supportDialog)
                    }
                }
                MenuItem {
                    id: aboutMenuItem
                    text: qsTr("About")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.pop()
                        stackView.push(aboutDialog)
                    }
                }
                /* for testing...
                MenuItem {
                    text: qsTr("WASM Open")
                    onTriggered: {
                        applicationData.getOpenFileContentAsync("*.gpt")
                    }
                }
                MenuItem {
                    text: qsTr("WASM Save")
                    onTriggered: {
                        var textControl = getCurrentTextRef(stackView.currentItem)
                        if( textControl !== null )
                        {
                            applicationData.saveFileContentAsync(textControl.text, applicationData.getOnlyFileName(homePage.currentFileUrl))
                        }
                    }
                }
                */
                /*
                MenuItem {
                    text: qsTr("Test")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        //console.log(Product.PendingRegistration)    // == 1
                        //console.log(Product.Registered)             // == 2
                        //console.log(Product.Unknown)                // == 3

                        showInfoDialog("installed = "+applicationData.isMobileGnuplotViewerInstalled, "Info")
                    }
                }
                MenuItem {
                    text: qsTr("Test for app")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        var s = homePage.textArea.text
                        showInfoDialog("installed? >" + s + "< = "+applicationData.isAppInstalled(s), "Info")
                    }
                }
                */
            }
        }


        ToolButton {
            id: toolButton
            //text: stackView.depth > 1 ? "\u25C0" : "\u2261"  // original: "\u2630" for second entry, does not work on Android
            icon.source: stackView.depth > 1 ? "back" : "menu_bars"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.left: parent.left
            anchors.leftMargin: 5
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        ToolButton {
            id: undoIcon
            icon.source: "back-arrow.svg"
            visible: stackView.currentItem === homePage || stackView.currentItem === outputPage || stackView.currentItem === helpPage
            enabled: writableIcon.checked && ((stackView.currentItem === homePage && homePage.textArea.canUndo) || (stackView.currentItem === outputPage && outputPage.txtOutput.canUndo) || (stackView.currentItem === helpPage && helpPage.txtHelp.canUndo))
            anchors.right: redoIcon.left
            anchors.rightMargin: 1
            onClicked: {
                menuUndo.clicked()
            }
        }

        ToolButton {
            id: redoIcon
            icon.source: "redo-arrow.svg"
            visible: stackView.currentItem === homePage || stackView.currentItem === outputPage || stackView.currentItem === helpPage
            enabled: writableIcon.checked && ((stackView.currentItem === homePage && homePage.textArea.canRedo) || (stackView.currentItem === outputPage && outputPage.txtOutput.canRedo) || (stackView.currentItem === helpPage && helpPage.txtHelp.canRedo))
            anchors.right: writableIcon.left
            anchors.rightMargin: 1
            onClicked: {
                menuRedo.clicked()
            }
        }

        ToolButton {
            id: writableIcon
            icon.source: "edit.svg"
            checkable: true
            checked: (stackView.currentItem === homePage && !homePage.textArea.readOnly) || (stackView.currentItem === outputPage && !outputPage.txtOutput.readOnly) || (stackView.currentItem === helpPage && !helpPage.txtHelp.readOnly)
            visible: stackView.currentItem === homePage || stackView.currentItem === outputPage || stackView.currentItem === helpPage
            anchors.right: menuButton.left //readonlySwitch.left
            anchors.rightMargin: 5

            onToggled: {
                var textControl = getCurrentTextRef(stackView.currentItem)
                if( textControl !== null )
                {
                    textControl.readOnly = !writableIcon.checked
                }
            }
        }

        ToolButton {
            id: supportIcon
            icon.source: "high-five.svg"
            visible: isAppStoreSupported && isCurrentUserSupporter()
            anchors.left: toolButton.right
            anchors.leftMargin: 1

            onClicked: {
                showThankYouDialog(settings.supportLevel)
            }
        }

        Label {
            text: stackView.currentItem.title
            //anchors.centerIn: parent
            anchors.left: supportIcon.visible ? supportIcon.right : toolButton.right
            anchors.right: undoIcon.visible ? undoIcon.left : (writableIcon.visible ? writableIcon.left : menuButton.left) //menuButton.left
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ToolBar {
        id: toolBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: settings.useToolBar
        height: settings.useToolBar ? implicitHeight : 0

        Flow {
            id: flow
            anchors.fill: parent
            spacing: 5

            ToolButton {
                id: toolButtonOpen
                icon.source: "open-folder-with-document.svg"
                enabled: stackView.currentItem === homePage
                //text: "Open"
                onClicked: {
                    homePage.do_open_file()
                }
            }
            ToolButton {
                id: toolButtonSave
                icon.source: "floppy-disk.svg"
                enabled: stackView.currentItem === homePage
                //text: "Open"
                onClicked: {
                    homePage.do_save_file()
                }
            }
            ToolButton {
                id: toolButtonRun
                icon.source: "play-button-arrowhead.svg"
                enabled: stackView.currentItem === homePage || stackView.currentItem === helpPage
                //text: "Run"
                onClicked: {
                    if(stackView.currentItem === homePage) {
                        homePage.run_gnuplot()
                    } else if(stackView.currentItem === helpPage) {
                        helpPage.run_help()
                    }
                }
            }
            ToolSeparator {
            }
            ToolButton {
                id: toolButtonShare
                icon.source: "share.svg"
                visible: isShareSupported
                //text: "Run"
                onClicked: {
                    if(stackView.currentItem === graphicsPage) {
                        sharePng.triggered()
                    } else {
                        shareText.triggered()
                    }
                }
            }
            ToolSeparator {
                visible: isShareSupported
            }
            ToolButton {
                id: toolButtonInput
                icon.source: "document.svg"
                //text: "Input"
                onClicked: {
                    stackView.pop()
                    stackView.push(homePage)
                }
            }
            ToolButton {
                id: toolButtonOutput
                icon.source: "log-format.svg"
                //text: "Output"
                onClicked: {
                    stackView.pop()
                    stackView.push(outputPage)
                }
            }
            ToolButton {
                id: toolButtonGraphics
                icon.source: "line-chart.svg"
                //text: "Graphics"
                onClicked: {
                    stackView.pop()
                    stackView.push(graphicsPage)
                }
            }
            ToolButton {
                id: toolButtonHelp
                icon.source: "information.svg"
                //text: "Help"
                onClicked: {
                    stackView.pop()
                    stackView.push(helpPage)
                }
            }
        }
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

    StackView {
        id: stackView
        initialItem: homePage
        //anchors.fill: parent
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        //height: 250
        //height: parent.height
    }

    // **********************************************************************
    // *** some (gui and not gui) components for the application
    // **********************************************************************

    Settings {
        id: settings
        property string currentFile: isAndroid ? "file:///data/data/de.mneuroth.gnuplotviewerquick/files/scripts/default.gpt" : ":/default.gpt"
        property bool useGnuplotBeta: false
        property bool useToolBar: false
        property int graphicsResolution: 1024
        property int graphicsFontSize: 28
        property var currentFont: null
        property int invokeCount: 0

        property int supportLevel: -1   // no support level at all
    }

    GnuplotInvoker {
        id: gnuplotInvoker

        resolution: settings.graphicsResolution
        fontSize: settings.graphicsFontSize
        useBeta: settings.useGnuplotBeta
        invokeCount: settings.invokeCount
    }

//    StorageAccess {
//        id: storageAccess
//    }

    PageHome {
        id: homePage
        objectName: "homePage"

        property string currentFileUrl: window.currentFile
    }

    PageGraphics {
        id: graphicsPage
        objectName: "graphicsPage"
        visible: false

        property string svgdata: ""
    }

    PageHelp {
        id: helpPage
        objectName: "helpPage"
        visible: false
    }

    PageOutput {
        id: outputPage
        objectName: "outputPage"
        visible: false
    }

    // **********************************************************************
    // *** some dialogs for the application
    // **********************************************************************

    AboutDialog {
        id: aboutDialog
        visible: false
    }

    SupportDialog {
        id: supportDialog
        visible: false
    }

    SettingsDialog {
        id: settingsDialog
        visible: false
    }

    MobileFileDialog {
        id: mobileFileDialog
        visible: false
    }
/*
    FontDialog {
        id: fontDialog
        visible: false

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
*/
/*
    // only for testing...
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
*/
    MessageDialog {
        id: infoDialog
        visible: false
        title: qsTr("Error")
        standardButtons: StandardButton.Ok
        onAccepted: {
            console.log("Close error msg")
        }
    }

    MessageDialog {
        id: myUserNotificationDialog
        visible: false
        title: qsTr("Request for support")
        text: qsTr("It seemed you like this app.\nMaybe you would like to support the development of this app with buying a support level?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            stackView.pop()
            stackView.push(supportDialog)
        }
        onNo: {
            // do nothing
        }
    }

    MessageDialog {
        id: askForClearDialog
        visible: false
        title: qsTr("Question")
        text: qsTr("Current text is changed, really discard the changed text?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            clearCurrentText()
        }
        onNo: {
            // do nothing
        }
    }

    Loader
    {
        id: storeLoader
        source: isAppStoreSupported ? "ApplicationStore.qml" : ""
    }

    // **********************************************************************
    // *** some signal handlers for the application
    // **********************************************************************

    Connections {
        target: applicationData

        onSendDummyData: {
            console.log("========> Dummy Data !!! "+txt+" "+value)
        }

        // used for WASM platform:
        onReceiveOpenFileContent: {
            setScriptName(fileName)
            setScriptText(fileContent)
        }
    }

    Connections {
        target: gnuplotInvoker

        onSigShowErrorText: {
            showInOutput(txt, bShowOutputPage)
        }
    }

    Connections {
        target: storageAccess

        onOpenFileContentReceived: {
            //applicationData.logText("==> onOpenFileContentReceived "+fileUri+" "+decodedFileUri)
// TODO does not work (improve!):            window.readCurrentDoc(fileUri) --> stackView.pop() not working
            homePage.currentFileUrl = fileUri
            homePage.textArea.text = content // window.readCurrentDoc(fileUri)  //content
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)
            stackView.pop()
        }
        onOpenFileCanceled: {
            stackView.pop()
        }
        onOpenFileError: {
            homePage.textArea.text = message
            stackView.pop()
        }
        onCreateFileReceived: {
            // create file is used for save as handling !
            //applicationData.logText("onCreateFileReceived "+fileUri)
            homePage.currentFileUrl = fileUri
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)
            // fill content into the newly created file...
            mobileFileDialog.saveAsCurrentFileNow(fileUri)
            //stackView.pop()   // already done in saveAs... above
        }
    }
}
