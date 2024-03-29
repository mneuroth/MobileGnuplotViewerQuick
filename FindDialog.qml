/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0

FindDialogForm {
    id: root

    signal canceled()
    signal accepted()

    findWhatInput {
        onAccepted: findNextButton.clicked()
    }

    clearfindWhatInputButton {
        onClicked: {
            findWhatInput.text = ""
        }
    }

    cancelButton {
        onClicked: canceled()
    }

    findNextButton {
        onClicked: accepted()
    }
}
