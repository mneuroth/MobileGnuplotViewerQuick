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
import QtQuick.Controls 2.2

PageHomeForm {

    property bool isInInit: true
    property string modifiedFlag: " (*)"

    fontName: getFontName()

    function addModifiedFlag() {
        var name = lblFileName.text
        if( !name.endsWith(modifiedFlag))
        {
            lblFileName.text = name + modifiedFlag
        }
    }

    function removeModifiedFlag() {
        var name = lblFileName.text
        if( name.endsWith(modifiedFlag))
        {
            name = name.substring( 0, name.length-modifiedFlag.length )
            lblFileName.text = name
        }
    }

    function do_save_file() {
        if( applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.saveFileContentAsync(homePage.textArea.text, applicationData.getOnlyFileName(homePage.currentFileUrl))
        }
        else
        {
            saveCurrentDoc(homePage.textArea)
        }
    }

    function do_open_file() {
        if( applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.getOpenFileContentAsync("*.gpt")
        }
        else
        {
            //fileDialog.open()
            //mobileFileDialog.open()
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

    function run_gnuplot() {
        // special handling for meta commands like: admin=1/0
        var cmd = homePage.textArea.text
        if( cmd.startsWith("admin=") )
        {
            var value = cmd.startsWith("admin=1") ? true : false
            applicationData.isAdmin = value
            outputPage.txtOutput.text += "Admin-Modus = "+value+"\n"
        }
        else
        {
            outputPage.txtOutput.text += qsTr("Running gnuplot for file ")+homePage.currentFileUrl+"\n"
            var sData = gnuplotInvoker.run(homePage.textArea.text)
            var sErrorText = gnuplotInvoker.lastError
            //outputPage.txtOutput.text += sErrorText   // not needed here, because error text will be updated in output via sigShowErrorText() asynchroniously !
            jumpToEndOfOutput()
            if( sErrorText.length>0 )
            {
                graphicsPage.lblShowGraphicsInfo.text = qsTr("There are informations or errors on the output page")
            }
            else
            {
                graphicsPage.lblShowGraphicsInfo.text = ""
            }
            // see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
            if( sData.length > 0 )
            {
                if(applicationData.isWASM) {
                    // TODO: bug in wasm qt 5.15.2 ?
                    // first clear and then assigne new content again
                    graphicsPage.image.source = "empty.svg"
                    graphicsPage.image.source = "file:///temp.svg"
                }
                else {
                    graphicsPage.image.source = "data:image/svg+xml;utf8," + sData
                }
                graphicsPage.svgdata = sData
                stackView.pop()
                stackView.push(graphicsPage)
            }
            else
            {
// TODO --> graphics page mit error Image fuellen
                graphicsPage.image.source = "empty.svg"
                stackView.pop()
                stackView.push(outputPage)
            }

            checkForUserNotification()
        }
    }

    textArea {
        //placeholderText: applicationData.defaultScript
        onTextChanged: {
            if( !isInInit )
            {
                // set modified flag for autosave of document
                textArea.textDocument.modified = true
                // and mark current file name with modified flag
                addModifiedFlag()
            }
        }
    }

    btnOpen  {
        onClicked:  {
            do_open_file()
        }
    }

    btnSave {
        onClicked: {
            do_save_file()
        }
    }

    btnRun {
        onClicked: {
            run_gnuplot()
        }
    }

    btnGraphics {
        onClicked: {
            stackView.pop()
            stackView.push(graphicsPage)
        }
    }

    btnOutput {
        onClicked: {
            stackView.pop()
            stackView.push(outputPage)
        }
    }

    btnHelp {
        onClicked: {
            stackView.pop()
            stackView.push(helpPage)
        }
    }
}
