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

PageOutputForm {

    fontName: getFontName()

    btnGraphics {
        onClicked: {
            stackView.pop()
            stackView.push(graphicsPage)
        }
    }

    btnInput {
        onClicked: {
            //stackView.push(homePage)
            stackView.pop()
        }
    }

    btnHelp {
        onClicked: {
            stackView.pop()
            stackView.push(helpPage)
        }
    }
}
