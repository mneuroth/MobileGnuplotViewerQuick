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

ReplaceDialogForm {
    id: root

    signal canceled()
    signal accepted()
    signal replace()
    signal replaceAll()

    findWhatInput {
        onAccepted: findNextButton.clicked()
    }

    replaceWithInput {
        onAccepted: findNextButton.clicked()
    }

    clearfindWhatInputButton {
        onClicked: {
            findWhatInput.text = ""
        }
    }

    clearReplaceWithInputButton {
        onClicked: {
            replaceWithInput.text = ""
        }
    }

    cancelButton {
        onClicked: canceled()
    }

    findNextButton {
        onClicked: accepted()
    }

    replaceButton {
        onClicked: replace()
    }

    replaceAllButton {
        onClicked: replaceAll()
    }

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            event.accepted = true
            cancelButton.clicked()
        }
    }
}
