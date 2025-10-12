/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
//import QtQuick.Dialogs 1.2 as Dialog      // Qt5
import Qt.labs.platform as DialogP
//import Qt.labs.settings
import QtQuick.Layouts

import Qt.labs.folderlistmodel

//import PicoTemplateApp

//import QtAndroidTools     // only for Android !!!

import de.mneuroth.gnuplotinvoker
//import de.mneuroth.storageaccess

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    width: 640
    height: 480
    title: qsTr("MobileGnuplotViewerQuick")

    property int defaultIconSize: 40
    property int iconSize: 40
    property int defaultButtonWidth: 100
    property int defaultButtonHeight: 40
    property int defaultMargins: 10
    property bool useMobileFileDialog: false
    property int currentSearchPos: 0
    property string currentSearchText: ""
    property string currentReplaceText: ""
    property bool currentIsReplace: false
    property bool matchWholeWord: false
    property bool caseSensitive: false
    property bool regExpr: false
    property string emptyString: "      "
    property string urlPrefix: "file://"    // or: ///
    property bool isAndroid: applicationData !== null ? applicationData.isAndroid : false
    property bool isShareSupported: applicationData !== null ? applicationData.isShareSupported : false
    property bool isAppStoreSupported: true //applicationData !== null ? applicationData.isAppStoreSupported : false

    property string currentFileName: qsTr("unknown.txt")
    property string currentDecodedFileName: ""
    property string currentDirectory: "."
    property string fileToDelete: ""

    property bool useToolBar: True

    Component.onDestruction: {
// TODO PATCH -> wird diese funktion in Qt 6 Android aufgerufen?
        console.log("DESTRUCTION: "+homePage.currentFileUrl)
        settings.currentFile = homePage.currentFileUrl
        settings.useGnuplotBeta = gnuplotInvoker.useBeta
        settings.syncXandYResolution = gnuplotInvoker.syncXandYResolution
        settings.graphicsResolutionX = gnuplotInvoker.resolutionX
        settings.graphicsResolutionY = gnuplotInvoker.resolutionY
        settings.graphicsFontSize = gnuplotInvoker.fontSize
        settings.invokeCount = gnuplotInvoker.invokeCount
        settings.currentFont = homePage.textArea.font
        settings.useToolBar = useToolBar
    }

    function addToLog(txt) {
        addToOutput(txt)
        console.log(txt)
    }

    Component.onCompleted: {
        homePage.currentFileUrl = settings.currentFile
        addToOutput("loading: "+settings.currentFile+"\n")
        console.log("loading: "+settings.currentFile+"\n")
        if( settings.currentFont !== null )
        {
            homePage.textArea.font = settings.currentFont
            homePage.textLineNumbers.font = settings.currentFont
            outputPage.txtOutput.font = settings.currentFont
            helpPage.txtHelp.font = settings.currentFont
        }

        homePage.textArea.font.pixelSize = settings.textFontSize
        homePage.textLineNumbers.font.pixelSize = settings.textFontSize
        outputPage.txtOutput.font.pixelSize = settings.textFontSize
        helpPage.txtHelp.font.pixelSize = settings.textFontSize

        if(homePage.currentFileUrl.length>0)
        {
            console.log("URL: "+homePage.currentFileUrl)
            readCurrentDoc(homePage.currentFileUrl)
        }

        // after changing the syntax highlighter the document is not changed !
        Qt.callLater( function () { applicationData.setSyntaxHighlighting(settings.useSyntaxHighlighter); homePage.removeModifiedFlag() } )    // Fires also a text change !

        console.log("use tooblar:"+settings.useToolBar)
        useToolBar = settings.useToolBar

        myStoreId.restorePurchases()
        console.log("tried to restore purchases from store ... "+myStoreId)

        if (Qt.platform.os === "android") {
            addToLog("\nComponent.onCompleted... "+QtAndroidTools+" "+QtAndroidSharing+" activity:"+QtAndroidTools.activityAction)
            addToLog("\nSEND="+QtAndroidTools.ACTION_SEND+" PICK="+QtAndroidTools.ACTION_PICK+" NONE="+QtAndroidTools.ACTION_NONE)
            addToLog("\nMimeTyp: "+QtAndroidTools.activityMimeType)
            addToLog("\nrecv TXT: "+QtAndroidSharing.getReceivedSharedText())

            if(QtAndroidTools.activityAction !== QtAndroidTools.ACTION_NONE)
            {
                if(QtAndroidTools.activityAction === QtAndroidTools.ACTION_SEND)
                {
                    if(QtAndroidTools.activityMimeType === "text/plain")
                    {
                        //addToLog("STARTING editing with received text")
                        Qt.callLater( function () { /*cancelTextEdit();*/ setScriptText(QtAndroidSharing.getReceivedSharedText()) } )
                    }
                }
                //addToLog("Android Acitivty Started... "+QtAndroidTools.activityAction)
                //addToLog("TEXT received: "+QtAndroidSharing.getReceivedSharedText())
            }
        }
        console.log("HOME_PATH: "+applicationData.homePath)
        console.log("SCRIPTS_PATH: "+applicationData.scriptsPath)
        console.log("FolderModel Path: "+folderModel.folder)
        addToOutput("HOME_PATH: "+applicationData.homePath+"\n")
        addToOutput("SCRIPTS_PATH: "+applicationData.scriptsPath+"\n")
        addToOutput("FolderModel Path: "+folderModel.folder+"\n")
    }

    onClosing: (close) => {
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

    function addToOutput(text) {
        outputPage.txtOutput.text += text
    }

    function setFileName(fileUri, decodedFileUri) {
        console.log("*** setFileName: "+fileUri+ " "+ decodedFileUri)
        homePage.currentFileUrl = fileUri       // PATCH
        homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)    // PATCH
        currentFileName = fileUri
        currentDecodedFileName = decodedFileUri        
    }

    function focusToEditor() {
        homePage.textArea.forceActiveFocus()
    }

    function processOpenFileCallback(fileName) {
        checkForModified()    // PATCH
        var content = applicationData.readFileContent(fileName)
        setFileName(fileName, null)
        homePage.textArea.text = content
        // we just read a file from disk -> the document is not modified yet !
        homePage.removeModifiedFlag()   // PATCH
    }

    function processSaveFileCallback(fileName) {
        var content = homePage.textArea.text
        setFileName(fileName, null)
        doSaveFile(currentFileName, content, true)
    }

    function doSaveFile(fileName, text, bForceSyncWrite) {
        if( !bForceSyncWrite && applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.saveFileContentAsync(text, applicationData.getOnlyFileName(fileName))
        }
        else
        {
            var ok = applicationData.writeFileContent(fileName, text)
            if( !ok )
            {
                var msg= /*localiseText*/(qsTr("ERROR: Can not save file ")) + fileName
                addErrorMessage(msg)
            }
        }
    }

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
        return (applicationData !== null && applicationData.isAndroid) ? (settings.supportLevel>=0 || (applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false)) : true
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
               stackView.currentItem === findDialog ||
               stackView.currentItem === replaceDialog ||
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

        var sAdd = "" // path.startsWith("/") ? "" : "/"
        var sUrl = urlPrefix + sAdd + path
        return sUrl
    }

    function saveCurrentDoc(textControl) {
        var ok = applicationData.writeFileContent(homePage.currentFileUrl, textControl.text)
        if(!ok)
        {
            var sErr = qsTr("Error writing file: "+homePage.currentFileUrl+"\n")
            applicationData.logText(sErr)
            outputPage.txtOutput.text += sErr
            stackView.push(outputPage)
        }
        else
        {
            homePage.textArea.textDocument.modified = false
            homePage.removeModifiedFlag()
        }
    }

    function saveCurrentGraphics(fileName) {
        applicationData.saveDataAsPngImage(fileName, graphicsPage.svgdata, gnuplotInvoker.resolutionX, gnuplotInvoker.resolutionY)
    }

    function saveAsImage(fullName) {
        saveCurrentGraphics(fullName)
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
        console.log("*** ReadCurrentDoc: "+url+ " "+urlFileName)
        homePage.currentFileUrl = urlFileName
        settings.currentFile = urlFileName          // PATCH
        addToOutput("readCurrentDoc="+urlFileName)
        console.log("readCurrentDoc="+urlFileName+" url: "+url)
        // do not update content of edit control in the case of an error !
        var content = applicationData.readFileContent(urlFileName)
        if( content !== applicationData.errorContent)
        {
            homePage.textArea.text = content
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = applicationData.getOnlyFileName(urlFileName)
            homePage.textArea.forceActiveFocus()
            // update the current directory after starting the application...
            mobileFileDialog.currentDirectory = applicationData.getLocalPathWithoutFileName(urlFileName)
            // we just read a file from disk -> the document is not modified yet !
            homePage.removeModifiedFlag()   // PATCH
        }
        else
        {
            var errorMessage = qsTr("Error reading ") + urlFileName;
            showInOutput(errorMessage, true)
        }
    }

    function showInOutput(sContent, bShowOutputPage) {
        outputPage.txtOutput.text += "\n" + sContent
        moveToEndOfText(outputPage.txtOutput)
        if(bShowOutputPage) {
            stackView.pop()
            stackView.push(outputPage)
        }
    }

    function showFileContentInOutput(sOnlyFileName) {
        var sFileName = applicationData.filesPath + sOnlyFileName
        var sContent = applicationData.readFileContent(buildValidUrl(sFileName))
        if( sContent !== applicationData.errorContent)
        {
            showInOutput(sContent, true)
        }
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

    function count_lines(text)
    {
        var lines = text.split(/\r\n|\r|\n/);
        return lines.length
    }

    function moveToEndOfText(textControl)
    {
        textControl.cursorPosition = textControl.text.length
        textControl.forceActiveFocus()
    }

    function searchForCurrentSearchText(bForward,bReplace,bQuiet)
    {
        var l = currentSearchText.length

        // could any search text be found in the current document?
        var pos = applicationData.findText(currentSearchText, 0, true, matchWholeWord, caseSensitive, regExpr)
        if(pos<0)
        {
            infoTextNotFound.open()
            currentIsReplace = false
        }
        else
        {
            pos = bForward ?
                        applicationData.findText(currentSearchText, currentSearchPos, true, matchWholeWord, caseSensitive, regExpr) :
                        applicationData.findText(currentSearchText, currentSearchPos-l, false, matchWholeWord, caseSensitive, regExpr)
            if(pos>=0)
            {
                homePage.textArea.cursorPosition = pos+l
                if( bReplace )
                {
                    homePage.textArea.remove(pos,pos+l)
                    homePage.textArea.insert(pos,currentReplaceText)
                }
                else
                {
                    homePage.textArea.select(pos,pos+l)
                }
                currentSearchPos = pos+l
                homePage.forceActiveFocus()
                return true
            }
            else
            {
                if( !bQuiet && !applicationData.isWASM)
                {
                    askForSearchFromTop.open()
                }

                currentSearchPos = bForward ? 0 : homePage.textArea.text.length

                return false
            }
        }
    }

    function isWhitespace(ch)
    {
        return ch===" " || ch==="\t" || ch==="\r" || ch==="\n"
    }

    function indexOf(pos, txt, bForward)
    {
        if( isWhitespace(txt[pos]) && pos>0 )
        {
            pos--;
        }

        var i = 0;
        var startPos = -1
        var direction = bForward ? 1 : -1
        var limit = bForward ? txt.length : 0
        while( pos+direction*i >=0 && startPos<0 )
        {
            var ch = txt[pos+direction*i]
            if( isWhitespace(ch) )
            {
                startPos = pos+direction*i + (bForward ? 0 : 1)
            }
            if( pos+direction*i==limit )
            {
                startPos = limit
            }
            i++;
        }
        return startPos;
    }

    function getWordUnderCursor(textControl)
    {
        if( textControl.selectedText.length>0 )
        {
            return textControl.selectedText
        }

        var txt = textControl.text
        var pos = textControl.cursorPosition

        var startPos = indexOf(pos, txt, false)
        var endPos = indexOf(pos, txt, true)
        var s = txt.substr(startPos, endPos-startPos)

        return s
    }

    function openSettingsDialog()
    {
        settingsDialog.txtGraphicsResolutionX.text = gnuplotInvoker.resolutionX
        settingsDialog.txtGraphicsResolutionY.text = gnuplotInvoker.resolutionY
        settingsDialog.chbSyncXAndYResolution.checked = gnuplotInvoker.syncXandYResolution
        settingsDialog.txtGraphicsFontSize.text = gnuplotInvoker.fontSize
        settingsDialog.txtTextFontSize.text = settings.textFontSize
        settingsDialog.chbUseGnuplotBeta.checked = gnuplotInvoker.useBeta
        settingsDialog.chbUseToolBar.checked = settings.useToolBar
        settingsDialog.chbUseSyntaxHighlighter.checked = settings.useSyntaxHighlighter
        settingsDialog.chbShowLineNumbers.checked = settings.showLineNumbers
        settingsDialog.chbUseLocalFiledialog.checked = applicationData.isUseLocalFileDialog
        settingsDialog.lblExampleText.font = homePage.textArea.font
        settingsDialog.txtAppStyle.text = settings.appStyle

        stackView.pop()
        stackView.push(settingsDialog)
    }

    function restoreDefaultSettings()
    {
        settingsDialog.txtGraphicsResolutionX.text = 1024
        settingsDialog.txtGraphicsResolutionY.text = 1024
        settingsDialog.chbSyncXAndYResolution.checked = true
        settingsDialog.txtGraphicsFontSize.text = 28
        settingsDialog.txtTextFontSize.text = 14
        settingsDialog.chbUseGnuplotBeta.checked = false
        settingsDialog.chbUseToolBar.checked = false
        settingsDialog.chbUseSyntaxHighlighter.checked = true
        settingsDialog.chbShowLineNumbers.checked = true
        settingsDialog.chbUseLocalFiledialog.checked = false
        //settingsDialog.lblExampleText.font = homePage.textArea.font
    }

    function startShareText(txt) {
        if (Qt.platform.os === "android") {
            QtAndroidSharing.shareText(txt)
        }
    }

    // **********************************************************************
    // *** some gui items for the application
    // **********************************************************************

    header: ToolBar {
        contentHeight: toolButton.implicitHeight
        id: firstToolBar

        ToolButton {
            id: menuButton
            //text: "\u22EE"
            icon.source: "files/menu.svg"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.right: parent.right
            anchors.leftMargin: 5
            onClicked: menu.open()

            Menu {
                id: menu
                //y: menuButton.height

                Menu {
                    id: menuSend
                    title: qsTr("Send")
                    enabled: isShareSupported
                    //visible: isShareSupported
                    //height: isShareSupported ? aboutMenuItem.height : 0

                    MenuItem {
                        text: qsTr("Send")
                        icon.source: "files/share.svg"
                        enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                        //visible: isShareSupported
                        //height: isShareSupported ? aboutMenuItem.height : 0
                        onTriggered: {
                            var s = getCurrentText(stackView.currentItem)
                            startShareText(s)
                            //var tempFileName = getTempFileNameForCurrent(stackView.currentItem)
                            //applicationData.shareText(tempFileName, s)
                        }
                    }
                    MenuItem {
                        id: shareText
                        text: qsTr("Send as text")
                        icon.source: "files/share.svg"
                        enabled: stackView.currentItem !== graphicsPage && !isDialogOpen()
                        //visible: isShareSupported
                        //height: isShareSupported ? aboutMenuItem.height : 0
                        onTriggered: {
                            var s = getCurrentText(stackView.currentItem)
                            startShareText(s)
                            //applicationData.shareSimpleText(s);
                        }
                    }
                    MenuItem {
                        id: sharePng
                        text: qsTr("Send as PDF/PNG")
                        icon.source: "files/share.svg"
                        enabled: !isDialogOpen() /*&& isCurrentUserSupporter()*/
                        //visible: isShareSupported
                        //height: isShareSupported ? aboutMenuItem.height : 0
                        onTriggered: {
                            if( isGraphicsPage(stackView.currentItem) )
                            {
                                var ok = applicationData.shareSvgData(graphicsPage.svgdata, gnuplotInvoker.resolutionX, gnuplotInvoker.resolutionY)
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
                        icon.source: "files/share.svg"
                        enabled: !isDialogOpen()
                        //visible: isShareSupported
                        //height: isShareSupported ? aboutMenuItem.height : 0
                        onTriggered: {
                            if( isGraphicsPage(stackView.currentItem) )
                            {
                                var ok = applicationData.shareViewSvgData(graphicsPage.svgdata, gnuplotInvoker.resolutionX, gnuplotInvoker.resolutionY)
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
                }
                MenuSeparator {
                    //visible: isShareSupported
                    //height: isShareSupported ? menuSeparator.height : 0
                }
                MenuItem {
                    text: qsTr("Writable")
                    icon.source: "files/edit.svg"
                    checkable: true
                    checked: writableIcon.checked
                    enabled: !isDialogOpen() && (stackView.currentItem === homePage || stackView.currentItem === outputPage || stackView.currentItem === helpPage)
                    onTriggered: {
                        writableIcon.toggle()
                    }
                }
                MenuItem {
                    id: menuClear
                    text: qsTr("Clear/New")
                    icon.source: "files/close.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        if( isGraphicsPage(stackView.currentItem) )
                        {
                            graphicsPage.image.source = "files/empty.svg"
                        }
                        else
                        {
                            var textControl = getCurrentTextRef(stackView.currentItem)
                            if( textControl.textDocument.modified && !applicationData.isWASM )
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
                    text: qsTr("Export file")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        fileDialog.fileMode = FileDialog.SaveFile
                        fileDialog.open()
                    }
                }
                MenuItem {
                    text: qsTr("Import file")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        fileDialog.fileMode = FileDialog.OpenFile
                        fileDialog.open()
                    }
                }
                MenuItem {
                    id: saveAsMenuItem
                    text: qsTr("Save as")
                    enabled: !isDialogOpen() && stackView.currentItem === homePage
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
                                if( useMobileFileDialog ) {
                                    mobileFileDialog.textControl = textControl
                                    mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                                    mobileFileDialog.setSaveAsModus(false)
                                    stackView.pop()
                                    stackView.push(mobileFileDialog)
                                } else {
                                    saveAsPage.saveAsInput.text = applicationData.getOnlyFileName(homePage.currentFileUrl)
                                    stackView.pop()
                                    stackView.push(saveAsPage)
                                }
                            }
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Delete files")
                    enabled: !isDialogOpen()
                    visible: useMobileFileDialog
                    height: useMobileFileDialog ? saveAsMenuItem.height : 0
                    onTriggered: {
                        mobileFileDialog.textControl = null
                        mobileFileDialog.setDirectory(mobileFileDialog.currentDirectory)
                        mobileFileDialog.setDeleteModus()
                        stackView.pop()
                        stackView.push(mobileFileDialog)
                    }
                }
                Menu {
                    id: searchMenu
                    title: qsTr("Search")

                    MenuItem {
                        id: findMenu
                        text: qsTr("Find")
                        icon.source: "files/search.svg"
                        enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                        onTriggered: toolButtonSearch.clicked()
                    }
                    MenuItem {
                        id: replaceMenu
                        text: qsTr("Replace")                        
                        icon.source: "files/replace.svg"
                        enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/
                        onTriggered: toolButtonReplace.clicked()
                    }
                    MenuItem {
                        id: previousFindMenu
                        text: qsTr("Previous")
                        icon.source: "files/left-arrow.svg"
                        enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/ && currentSearchText.length>0
                        onTriggered: toolButtonPrevious.clicked()
                    }
                    MenuItem {
                        id: nextFindMenu
                        text: qsTr("Next")
                        icon.source: "files/right-arrow.svg"
                        enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/ && currentSearchText.length>0
                        onTriggered: toolButtonNext.clicked()
                    }
                }
                MenuSeparator {
                    id: menuSeparator
                }
                MenuItem {
                    id: menuUndo
                    icon.source: "files/back-arrow.svg"
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
                    icon.source: "files/redo-arrow.svg"
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
                            showInOutput(sContent+gnuplotInvoker.lastError, true)
                        }
                    }
                    MenuItem {
                        text: qsTr("Gnuplot version")
                        onTriggered: {
                            var sContent = gnuplotInvoker.run("show version")
                            showInOutput(sContent+gnuplotInvoker.lastError, true)
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Settings")
                    icon.source: "files/settings.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        openSettingsDialog()
                    }
                }
                MenuItem {
                    id: supportMenuItem
                    text: qsTr("Support")
                    icon.source: "files/coin.svg"
                    enabled: !isDialogOpen() && isAppStoreSupported
                    visible: isAppStoreSupported
                    //height: isAppStoreSupported ? aboutMenuItem.height : 0
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
                MenuItem {
                    id: toggleAdminMenuItem
                    text: qsTr("Admin Modus")
                    enabled: !isDialogOpen()
                    checkable: true
                    onTriggered: {
                        mobileFileDialog.setAdminModus(toggleAdminMenuItem.checked)
                        console.log("admin mode:"+toggleAdminMenuItem.checked)
                    }
                }

                MenuItem {
                    id: testMenuItem
                    text: qsTr("TEST")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        homePage.do_open_file(/*useMobileFileDialog*/true)
                        //stackView.pop()
                        //stackView.push(simpleFileListDialog)
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
            icon.source: stackView.depth > 1 ? "files/back.svg" : "files/menu_bars.svg"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.left: parent.left
            anchors.leftMargin: 5
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                    homePage.textArea.forceActiveFocus()
                } else {
                    drawer.open()
                }
            }
        }

        ToolButton {
            id: undoIcon
            icon.source: "files/back-arrow.svg"
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
            icon.source: "files/redo-arrow.svg"
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
            icon.source: "files/edit.svg"
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
            icon.source: "files/high-five.svg"
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
        visible: useToolBar  // gulp
        //height: settings.useToolBar ? implicitHeight : 0
        //height: settings.useToolBar ? firstToolBar.height*1.4 : 0 //flow.implicitHeight/*implicitHeight*/ : 0     // for qt6
        height: useToolBar ? flow.implicitHeight/*implicitHeight*/ : 0

        onHeightChanged: {
            if( toolBar.height>2*iconSize+flow.spacing ) {
                iconSize -= 2
            } else if ( toolBar.height<defaultIconSize ) {
                if( iconSize<defaultIconSize ) {
                    iconSize += 1
                }
            }
        }

        Flow {
            id: flow
            anchors.fill: parent
            spacing: 5

            ToolButton {
                id: toolButtonOpen
                icon.source: "files/open-folder-with-document.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Open"
                onClicked: {
                    homePage.do_open_file(useMobileFileDialog)
                }
            }
            ToolButton {
                id: toolButtonSave
                icon.source: "files/floppy-disk.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Open"
                onClicked: {
                    homePage.do_save_file()
                }
            }
            ToolButton {
                id: toolButtonClear
                icon.source: "files/close.svg"
                height: iconSize
                width: height
                enabled: menuClear.enabled
                //text: "Clear"
                onClicked: {
                    menuClear.clicked()
                }
            }
            ToolButton {
                id: toolButtonRun
                icon.source: "files/play-button-arrowhead.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage || stackView.currentItem === helpPage) && !isDialogOpen()
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
                height: iconSize
            }
            ToolButton {
                id: toolButtonSearch
                icon.source: "files/search.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Search"
                onClicked: {
                    //var currentTextControl = getCurrentTextRef(stackView.currentItem) // needed to search in outputPage (maybe)
                    var search = getWordUnderCursor(homePage.textArea)
                    findDialog.findWhatInput.text = search
                    findDialog.matchWholeWordCheckBox.checked = matchWholeWord
                    findDialog.caseSensitiveCheckBox.checked = caseSensitive
                    findDialog.regularExpressionCheckBox.checked = regExpr

                    stackView.pop()
                    stackView.push(findDialog)

                    findDialog.findWhatInput.forceActiveFocus()
                }
            }
            ToolButton {
                id: toolButtonReplace
                icon.source: "files/replace.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/
                //text: "Replace"
                onClicked: {
                    var currentTextControl = getCurrentTextRef(stackView.currentItem)
                    var search = getWordUnderCursor(currentTextControl)
                    replaceDialog.findWhatInput.text = search
                    replaceDialog.matchWholeWordCheckBox.checked = matchWholeWord
                    replaceDialog.caseSensitiveCheckBox.checked = caseSensitive
                    replaceDialog.regularExpressionCheckBox.checked = regExpr
                    replaceDialog.replaceWithInput.text = currentReplaceText

                    stackView.pop()
                    stackView.push(replaceDialog)

                    replaceDialog.findWhatInput.forceActiveFocus()
                }
            }
            ToolButton {
                id: toolButtonPrevious
                icon.source: "files/left-arrow.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/ && currentSearchText.length>0
                //text: "Previous"
                onClicked: {
                    searchForCurrentSearchText(false,currentIsReplace,false)
                }
            }
            ToolButton {
                id: toolButtonNext
                icon.source: "files/right-arrow.svg"
                height: iconSize
                width: height
                enabled: (stackView.currentItem === homePage) && !isDialogOpen() /*&& isCurrentUserSupporter()*/ && currentSearchText.length>0
                //text: "Next"
                onClicked: {
                    searchForCurrentSearchText(true,currentIsReplace,false)
                }
            }
            ToolSeparator {
                height: iconSize
            }
            ToolButton {
                id: toolButtonSettings
                icon.source: "files/settings.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen()
                //text: "Settings"
                onClicked: {
                    openSettingsDialog()
                }
            }
            ToolButton {
                id: toolButtonSettingsSupport
                icon.source: "files/coin.svg"
                height: iconSize
                width: height
                visible: isAppStoreSupported
                enabled: !isDialogOpen() && isAppStoreSupported
                //text: "Support/donate"
                onClicked: {
                    supportMenuItem.clicked()
                }
            }
            ToolSeparator {
                height: iconSize
            }
            ToolButton {
                id: toolButtonShare
                icon.source: "files/share.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen()
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
                height: iconSize
                visible: isShareSupported
            }
            ToolButton {
                id: toolButtonInput
                icon.source: "files/document.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen() && stackView.currentItem !== homePage
                checkable: true
                checked: stackView.currentItem === homePage
                //text: "Input"
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                    }
                    homePage.textArea.forceActiveFocus()
                }
            }
            ToolButton {
                id: toolButtonOutput
                icon.source: "files/log-format.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen() && stackView.currentItem !== outputPage
                checkable: true
                checked: stackView.currentItem === outputPage
                //text: "Output"
                onClicked: {
                    stackView.pop()
                    stackView.push(outputPage)
                    outputPage.txtOutput.forceActiveFocus()
                }
            }
            ToolButton {
                id: toolButtonGraphics
                icon.source: "files/line-chart.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen() && stackView.currentItem !== graphicsPage
                checkable: true
                checked: stackView.currentItem === graphicsPage
                //text: "Graphics"
                onClicked: {
                    stackView.pop()
                    stackView.push(graphicsPage)
                }
            }
            ToolButton {
                id: toolButtonHelp
                icon.source: "files/information.svg"
                height: iconSize
                width: height
                enabled: !isDialogOpen()
                checkable: true
                checked: stackView.currentItem === helpPage
                //text: "Help"
                onClicked: {
                    stackView.pop()
                    stackView.push(helpPage)
                    helpPage.txtHelp.forceActiveFocus()
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
        property string appStyle: "Material"
        property string currentFile: isAndroid ? "file:///data/data/de.mneuroth.gnuplotviewerquick/files/scripts/default.gpt" : ":/default.gpt"
        property bool useGnuplotBeta: false
        property bool useToolBar: true //false
        property bool useSyntaxHighlighter: true
        property bool showLineNumbers: true
        property bool syncXandYResolution: true
        property int graphicsResolutionX: 1024
        property int graphicsResolutionY: 1024
        property int graphicsFontSize: 28
        property int textFontSize: 14
        property var currentFont: null
        property int invokeCount: 0

        property int supportLevel: -1   // no support level at all
    }

    GnuplotInvoker {
        id: gnuplotInvoker

        syncXandYResolution: settings.syncXandYResolution
        resolutionX: settings.graphicsResolutionX
        resolutionY: settings.graphicsResolutionY
        fontSize: settings.graphicsFontSize
        useBeta: settings.useGnuplotBeta
        invokeCount: settings.invokeCount
    }
/*
    StorageAccess {
        id: storageAccess
    }
*/
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

    SaveAsDialog {
        id: saveAsPage
        objectName: "saveAsPage"
        visible: false
    }

    FolderListModel {
        id: folderModel
        //folder: "file:///c:/tmp" //applicationData.homePath // "." //"file:///sdcard/"   // Pfad anpassen
        //folder: "file:///data/data/de.mneuroth.gnuplotviewerquick/files/scripts" //+applicationData.homePath //"file:///D:/Users/micha/Documents/git_projects/GnuplotViewerQuickQt6/build/Desktop_Qt_6_7_3_MSVC2019_64bit-Debug"
        //folder: applicationData !== null ? urlPrefix+applicationData.getScriptsPath() : ""
        folder: applicationData !== null ? urlPrefix+applicationData.getScriptsPath() : ""
        showDirs: false
        showDotAndDotDot: false
        nameFilters: ["*.txt", "*.gpt", "*.dat", "*.csv", "*.*"]          // Filter, z. B. ["*.txt"]
    }

    Page {
        id: simpleFileListDialog
        title: qsTr("Scripts")
        anchors.fill: parent
        anchors.margins: defaultMargins
        visible: false

        contentItem: ColumnLayout {
            anchors.fill: parent
            spacing: 20

        ListView {
            id: scriptsList
            //anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true
            //anchors.rightMargin: 12
            model: folderModel
            delegate: RowLayout {
                width: parent !== null ? parent.width-scrollbar.width : 100
                spacing: 10

                Label {
                    text: fileName
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                    font.pixelSize: settings.textFontSize //16
                    //width: parent.width * 0.7

                    MouseArea {
                         anchors.fill: parent
                         onClicked: {
                             console.log("Geklickt:", fileURL)
                             // Optional: Signal auslösen oder Funktion aufrufen
                             processOpenFileCallback(fileURL)
                             stackView.pop()
                         }
                     }
                }
                Button {
                    text: qsTr("X")    // ❌ 🗑️ X
                    font.pixelSize: settings.textFontSize
                    Layout.maximumWidth: 20
                    width: 20
                    onClicked: {
                        fileToDelete = fileURL
                        askForDeleteFile.open()
                        console.log("folder: "+folderModel.folder)
                    }
                }
                Button {
                    text: qsTr(">")   // Export: ⬆ U+2B06 or ->
                    font.pixelSize: settings.textFontSize
                    Layout.maximumWidth: 20
                    width: 20
                    onClicked: {
                        console.log("EXPORT Geklickt:", fileURL)
                        fileDialog.fileMode = FileDialog.SaveFile
                        fileDialog.open()
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                id: scrollbar
                policy: ScrollBar.AsNeeded  // zeigt sich nur bei Bedarf
                anchors.top: scriptsList.top
                anchors.bottom: scriptsList.bottom
                anchors.right: scriptsList.right
            }
        }

        Button {
            text: qsTr("Close")
            Layout.preferredWidth: defaultButtonWidth
            Layout.preferredHeight: defaultButtonHeight
            Layout.alignment: Qt.AlignBottom
            onClicked: {
                stackView.pop()
            }
        }

        }
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

    FindDialog {
        id: findDialog
        visible: false
    }

    ReplaceDialog {
        id: replaceDialog
        visible: false
    }

    MobileFileDialog {
        id: mobileFileDialog
        visible: false
        pathsSDCard: applicationData !== null ? applicationData.getSDCardPaths() : []// TODO PATCH
        Component.onCompleted: {
// PATCH            mobileFileDialog.isWASM = applicationData.isWASM
        }
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
    DialogP.MessageDialog {
        id: infoDialog
        visible: false
        title: qsTr("Error")
        //standardButtons: StandardButton.Ok
        buttons: DialogP.MessageDialog.Ok
        onAccepted: {
            console.log("Close error msg")
        }
    }

    DialogP.MessageDialog {
        id: myUserNotificationDialog
        visible: false
        title: qsTr("Request for support")
        text: qsTr("It seemed you like this app.\nMaybe you would like to support the development of this app with buying a support level?")
        //standardButtons: StandardButton.Yes | StandardButton.No
        buttons: DialogP.MessageDialog.Yes | DialogP.MessageDialog.No
        onYesClicked: {
            stackView.pop()
            stackView.push(supportDialog)
        }
        //onNoClicked: {
        //    // do nothing
        //}
    }

    DialogP.MessageDialog {
        id: askForClearDialog
        visible: false
        title: qsTr("Question")
        text: qsTr("Current text is changed, really discard the changed text?")
        //standardButtons: StandardButton.Yes | StandardButton.No
        buttons: DialogP.MessageDialog.Yes | DialogP.MessageDialog.No
        onYesClicked: {
            clearCurrentText()
        }
        onNoClicked: {
            // do nothing
        }
    }

    DialogP.MessageDialog {
        id: infoTextNotFound
        visible: false
        title: qsTr("Information")
        text: qsTr("Search text not found!")
        //standardButtons: StandardButton.Ok
        buttons: DialogP.MessageDialog.Ok
        onAccepted: {
        }
    }

    // MessageDialogs does not work for WASM platform !
    DialogP.MessageDialog {
        id: askForSearchFromTop
        visible: false
        title: qsTr("Question")
        text: qsTr("Reached end of text, search again from the top?")
        //standardButtons: StandardButton.Yes | StandardButton.No
        buttons: DialogP.MessageDialog.Yes | DialogP.MessageDialog.No
        onYesClicked: {
            toolButtonNext.clicked()
        }
        onNoClicked: {
            // do nothing
            homePage.textArea.forceActiveFocus()
        }
    }

    DialogP.MessageDialog {
        id: askForDeleteFile
        visible: false
        title: qsTr("Question")
        text: qsTr("Really delete this file?")
        //standardButtons: StandardButton.Yes | StandardButton.No
        buttons: DialogP.MessageDialog.Yes | DialogP.MessageDialog.No
        onYesClicked: {
            var ok = applicationData.deleteFile(fileToDelete)
            console.log("ok? -> "+ok)
        }
        onNoClicked: {
            // do nothing
        }
    }

    FileDialog {
        id: fileDialog
        selectedNameFilter.index: 0
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: {
            var fileName = ""+fileDialog.selectedFile
            if (fileDialog.fileMode == FileDialog.OpenFile) {
                processOpenFileCallback(fileName)
            } else {
                processSaveFileCallback(fileName)
            }


        }
        onRejected: {
            console.log("File selection canceled")
        }
    }

/*
    Loader
    {
        id: storeLoader
        source: isAppStoreSupported ? "ApplicationStore.qml" : ""
    }
*/

    Store {
        id: myStoreId
    }


    Product {
        id: supportLevel0
        identifier: "support_level_0"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false

        onPurchaseSucceeded: {
            //showInfoDialog(qsTr("Purchase successfull."))
            settings.supportLevel = 0

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            showInfoDialog(qsTr("Purchase restored."))
            settings.supportLevel = 0

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    Product {
        id: supportLevel1
        identifier: "support_level_1"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false

        onPurchaseSucceeded: {
            settings.supportLevel = 1

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            settings.supportLevel = 1

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    Product {
        id: supportLevel2
        identifier: "support_level_2"
        store: myStoreId
        type: Product.Unlockable

        property bool purchasing: false


        onPurchaseSucceeded: {
            settings.supportLevel = 2

            transaction.finalize()

            showThankYouDialog(settings.supportLevel)

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showInfoDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            settings.supportLevel = 2

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }
    }

    // **********************************************************************
    // *** some signal handlers for the application
    // **********************************************************************

    Connections {
        target: replaceDialog

        function onCanceled() {
            stackView.pop()
        }
        function onAccepted() {
            stackView.pop()
            currentSearchPos = homePage.textArea.cursorPosition
            currentSearchText = replaceDialog.findWhatInput.text
            currentReplaceText = replaceDialog.replaceWithInput.text
            matchWholeWord = findDialog.matchWholeWordCheckBox.checked
            caseSensitive = findDialog.caseSensitiveCheckBox.checked
            regExpr = findDialog.regularExpressionCheckBox.checked

            currentIsReplace = false
            searchForCurrentSearchText(true,false,false)
        }
        function onReplace() {
            stackView.pop()
            currentSearchPos = homePage.textArea.cursorPosition
            currentSearchText = replaceDialog.findWhatInput.text
            currentReplaceText = replaceDialog.replaceWithInput.text
            matchWholeWord = findDialog.matchWholeWordCheckBox.checked
            caseSensitive = findDialog.caseSensitiveCheckBox.checked
            regExpr = findDialog.regularExpressionCheckBox.checked

            currentIsReplace = true
            searchForCurrentSearchText(true,true,false)
        }
        function onReplaceAll() {
            stackView.pop()
            currentSearchPos = homePage.textArea.cursorPosition
            currentSearchText = replaceDialog.findWhatInput.text
            currentReplaceText = replaceDialog.replaceWithInput.text
            matchWholeWord = findDialog.matchWholeWordCheckBox.checked
            caseSensitive = findDialog.caseSensitiveCheckBox.checked
            regExpr = findDialog.regularExpressionCheckBox.checked

            currentIsReplace = true
            var finished = false
            while(!finished)
            {
                finished = !searchForCurrentSearchText(true,true,true)
            }
            currentIsReplace = false
        }
    }

    Connections {
        target: findDialog

        function onCanceled() {
            stackView.pop()
            homePage.textArea.forceActiveFocus()
        }
        function onAccepted() {
            stackView.pop()
            currentSearchPos = homePage.textArea.cursorPosition
            currentSearchText = findDialog.findWhatInput.text
            matchWholeWord = findDialog.matchWholeWordCheckBox.checked
            caseSensitive = findDialog.caseSensitiveCheckBox.checked
            regExpr = findDialog.regularExpressionCheckBox.checked
            var backward = findDialog.backwardDirectionCheckBox.checked

            currentIsReplace = false
            searchForCurrentSearchText(!backward,false,false);
        }
    }

    Connections {
        target: saveAsPage

        function onCanceled() {
            stackView.pop()
            homePage.textArea.forceActiveFocus()
        }
        function onAccepted() {
            stackView.pop()
            var fileName = applicationData.scriptsPath + "/" + saveAsPage.saveAsInput.text
            console.log("SAVE AS: "+fileName)
            processSaveFileCallback(fileName)
        }
    }

    Connections {
        target: settingsDialog

        function onRestoreDefaultSettings() {
            restoreDefaultSettings()
        }
    }

    Connections {
        target: applicationData

        function onSendDummyData(txt, value) {
            console.log("========> Dummy Data !!! "+txt+" "+value)
        }

        function onShowErrorMsg(message) {
            stackView.pop()
            outputPage.txtOutput.text += message + "\n"
            stackView.push(outputPage)
        }

        // used for WASM platform:
        function onReceiveOpenFileContent(fileName, fileContent) {
            setScriptName(fileName)
            setScriptText(fileContent)
        }
    }

    Connections {
        target: gnuplotInvoker

        function onSigShowErrorText(txt) {
            //showInOutput(txt, bShowOutputPage)
        }
    }
/*
    Connections {
        target: storageAccess

        function onOpenFileContentReceived(fileUri, decodedFileUri, content) {
            //applicationData.logText("==> onOpenFileContentReceived "+fileUri+" "+decodedFileUri)
// TODO does not work (improve!):            window.readCurrentDoc(fileUri) --> stackView.pop() not working
            homePage.currentFileUrl = fileUri
            homePage.textArea.text = content // window.readCurrentDoc(fileUri)  //content
            homePage.textArea.textDocument.modified = false
            homePage.lblFileName.text = applicationData.getOnlyFileName(fileUri)
// TODO --> update focus ?
            stackView.pop()
        }
        function onOpenFileCanceled() {
            stackView.pop()
        }
        function onOpenFileError(message) {
            homePage.textArea.text = message
            stackView.pop()
        }
        function onCreateFileReceived(fileUri, decodedFileUri) {
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
*/
    Connections {
        target: mobileFileDialog

        //onRejected: stackView.pop()       // for Qt 5.12.xx
        function onRejected() {
            //addToOutput("mobileFileDialog Rejected")
            stackView.pop()
            focusToEditor()
        }
        function onAccepted() {
            //addToOutput("mobileFileDialog Accepted")
            currentDirectory = mobileFileDialog.lblDirectoryName.text
            stackView.pop()
            focusToEditor()
        }

        function onSaveSelectedFile(fileName) {
            processSaveFileCallback(fileName)
        }
        function onOpenSelectedFile(fileName) {
            //addToOutput("openSelectedFile="+fileName)
            console.log("*** openSelectedFile="+fileName)
            processOpenFileCallback(fileName)
        }
        function onDeleteSelectedFile(fileName) {
            var ok = applicationData.deleteFile(fileName)
            if( !ok ) {
                var msg= localiseText(qsTr("ERROR: Can not delete file ")) + fileName
                addErrorMessage(msg)
            }
        }

        function onStorageOpenFile() {
            //console.log("storage open")
            //addToOutput("storage open")
            storageAccess.openFile()
        }
        function onStorageCreateFile(fileNane) {
            //console.log("storage create file "+fileNane)
            //addToOutput("storage create file "+fileNane)
            setFileName(fileName, null)
            storageAccess.createFile(fileNane)
        }
    }
}
