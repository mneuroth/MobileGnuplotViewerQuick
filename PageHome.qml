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

    btnSave {
        onClicked: {
            saveCurrentDoc(homePage.textArea)
        }
    }

    btnRun {
        onClicked: {
            outputPage.txtOutput.text += qsTr("Running gnuplot for file ")+homePage.currentFileUrl+"\n"
            var sData = gnuplotInvoker.run(homePage.textArea.text)
            var sErrorText = gnuplotInvoker.lastError
            outputPage.txtOutput.text += sErrorText
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
                graphicsPage.image.source = "data:image/svg+xml;utf8," + sData
                graphicsPage.svgdata = sData
                stackView.pop()
                stackView.push(graphicsPage)
            }
            else
            {
// TODO --> graphics page mit error Image fuellen
                graphicsPage.image.source = ":/empty.svg"
                stackView.pop()
                stackView.push(outputPage)
            }
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
