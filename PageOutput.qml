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
