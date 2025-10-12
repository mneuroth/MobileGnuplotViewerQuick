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
import QtQuick.Layouts

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

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            event.accepted = true
            cancelButton.clicked()
        }
    }
}
