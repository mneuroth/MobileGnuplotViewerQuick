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
}
