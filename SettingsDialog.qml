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

    txtSupportLevel {
        visible: isAppStoreSupported
        text: (applicationData !== null ? applicationData.isMobileGnuplotViewerInstalled : false) ? "99" : settings.supportLevel
    }

    lblSupportLevel {
        visible: isAppStoreSupported
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
            applicationData.isUseLocalFileDialog = chbUseLocalFiledialog.checked
            settings.useToolBar = chbUseToolBar.checked
            settings.showLineNumbers = chbShowLineNumbers.checked
            var aFont = settingsDialog.lblExampleText.font
            homePage.textArea.font = aFont
            outputPage.txtOutput.font = aFont
            helpPage.txtHelp.font = aFont
            stackView.pop()
        }
    }
}
