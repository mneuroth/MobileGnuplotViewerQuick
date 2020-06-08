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

SettingsDialogForm {

    Component.onCompleted: {
        settingsDialog.btnSelectFont.visible = false
        settingsDialog.lblExampleText.visible = false
    }

    txtGraphicsResolution {
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
            gnuplotInvoker.resolution = parseInt(txtGraphicsResolution.text)
            gnuplotInvoker.useBeta = chbUseGnuplotBeta.checked
            gnuplotInvoker.fontSize = parseInt(txtGraphicsFontSize.text)
            var aFont = settingsDialog.lblExampleText.font
            homePage.textArea.font = aFont
            outputPage.txtOutput.font = aFont
            helpPage.txtHelp.font = aFont
            stackView.pop()
        }
    }
}
