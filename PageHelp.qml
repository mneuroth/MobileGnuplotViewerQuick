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

PageHelpForm {

    fontName: getFontName()

    function run_help() {
        var s = gnuplotInvoker.run(helpPage.txtHelp.text)
        var sErrorText = gnuplotInvoker.lastError
        outputPage.txtOutput.text += s
        outputPage.txtOutput.text += sErrorText
        stackView.pop()
        stackView.push(outputPage)
        moveToEndOfText(outputPage.txtOutput)
    }

    btnRunHelp {
        onClicked: {
            run_help()
        }
    }

    btnOutput {
        onClicked: {
            stackView.pop()
            stackView.push(outputPage)
        }
    }

    btnInput {
        onClicked: {
            //stackView.push(homePage)
            stackView.pop()
        }
    }
}
