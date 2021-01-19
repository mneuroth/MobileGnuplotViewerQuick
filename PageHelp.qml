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

PageHelpForm {

    fontName: getFontName()

    btnRunHelp {
        onClicked: {
            var s = gnuplotInvoker.run(helpPage.txtHelp.text)
            var sErrorText = gnuplotInvoker.lastError
            outputPage.txtOutput.text += s
            outputPage.txtOutput.text += sErrorText
            stackView.pop()
            stackView.push(outputPage)
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
