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
        validator: IntValidator { bottom: 128; top: 4096 }

        onTextChanged: {
            if( chbSyncXAndYResolution.checked ) {
                txtGraphicsResolutionY.text = txtGraphicsResolutionX.text
            }
        }
    }

    txtGraphicsResolutionY {
        validator: IntValidator { bottom: 128; top: 4096 }
    }

    txtGraphicsFontSize {
        validator: IntValidator { bottom: 6; top: 64 }
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
            gnuplotInvoker.resolutionX = parseInt(txtGraphicsResolutionX.text)
            gnuplotInvoker.resolutionY = parseInt(txtGraphicsResolutionY.text)
            gnuplotInvoker.syncXandYResolution = chbSyncXAndYResolution.checked
            gnuplotInvoker.useBeta = chbUseGnuplotBeta.checked
            gnuplotInvoker.fontSize = parseInt(txtGraphicsFontSize.text)
            applicationData.isUseLocalFileDialog = chbUseLocalFiledialog.checked
            settings.useToolBar = chbUseToolBar.checked
            settings.showLineNumbers = chbShowLineNumbers.checked
            settings.useSyntaxHighlighter = chbUseSyntaxHighlighter.checked
            var aFont = settingsDialog.lblExampleText.font
            homePage.textArea.font = aFont
            outputPage.txtOutput.font = aFont
            helpPage.txtHelp.font = aFont
            stackView.pop()
            if( applicationData.setSyntaxHighlighting(settings.useSyntaxHighlighter) ) {
                // simulate update of text to rehighlight text again
                //var txt = homePage.textArea.text
                //homePage.textArea.text = ""
                //homePage.textArea.text = txt
            }
        }
    }

    btnRestoreDefaultSettings {
        onClicked: {
            restoreDefaultSettings()
        }
    }
}
