/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick
import QtQuick.Controls

SettingsDialogForm {

    signal restoreDefaultSettings()

    Component.onCompleted: {
        settingsDialog.btnSelectFont.visible = false
        settingsDialog.lblExampleText.visible = false
    }

    chbSyncXAndYResolution {
        onCheckedChanged: {
            if( chbSyncXAndYResolution.checked ) {
                txtGraphicsResolutionY.text = txtGraphicsResolutionX.text
            }
        }
    }

    txtGraphicsResolutionX {
        onTextChanged: {
            if( chbSyncXAndYResolution.checked ) {
                txtGraphicsResolutionY.text = txtGraphicsResolutionX.text
            }
        }
    }

    btnIncTextFontSize {
        onClicked: {
            var val = parseInt(txtTextFontSize.text)
            if(val < maxFontSize) {
                val += 1
            }
            txtTextFontSize.text = val
        }
    }

    btnDecTextFontSize {
        onClicked: {
            var val = parseInt(txtTextFontSize.text)
            if(val > minFontSize) {
                val -= 1
            }
            txtTextFontSize.text = val
        }
    }

    btnSelectFont {
        onClicked: {
            fontDialog.font = lblExampleText.font
            fontDialog.currentFont = lblExampleText.font
            fontDialog.resultFcn = function (val) { lblExampleText.font = val }
            fontDialog.open()
        }
    }

    btnCancel {
        onClicked:  {
            stackView.pop()
        }
    }

    btnOk {
        onClicked:  {
            var isAlreadyModified = homePage.isModifiedFlagSet()
            gnuplotInvoker.resolutionX = parseInt(txtGraphicsResolutionX.text)
            gnuplotInvoker.resolutionY = parseInt(txtGraphicsResolutionY.text)
            gnuplotInvoker.syncXandYResolution = chbSyncXAndYResolution.checked
            gnuplotInvoker.useBeta = chbUseGnuplotBeta.checked
            gnuplotInvoker.fontSize = parseInt(txtGraphicsFontSize.text)
            applicationData.isUseLocalFileDialog = chbUseLocalFiledialog.checked
            settings.useToolBar = chbUseToolBar.checked
            useToolBar = chbUseToolBar.checked
            settings.textFontSize = parseInt(txtTextFontSize.text)
            settings.showLineNumbers = chbShowLineNumbers.checked
            settings.useSyntaxHighlighter = chbUseSyntaxHighlighter.checked
            settings.appStyle = txtAppStyle.text
            settingsDialog.lblExampleText.font.pixelSize = settings.textFontSize
            var aFont = settingsDialog.lblExampleText.font
            homePage.textArea.font = aFont
            homePage.textLineNumbers.font = aFont
            outputPage.txtOutput.font = aFont
            helpPage.txtHelp.font = aFont
            stackView.pop()
            if( applicationData.setSyntaxHighlighting(settings.useSyntaxHighlighter) ) {
                // simulate update of text to rehighlight text again
                //var txt = homePage.textArea.text
                //homePage.textArea.text = ""
                //homePage.textArea.text = txt
            }
            // after changing the syntax highlighter the document is not changed !
            if( !isAlreadyModified ) {
                homePage.removeModifiedFlag()
            }
        }
    }

    btnRestoreDefaultSettings {
        onClicked: {
            restoreDefaultSettings()
        }
    }

    Keys.onReleased: (event) => {
                         console.log("Key "+event.key)
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            event.accepted = true
            btnCancel.clicked()
        }
    }
}
