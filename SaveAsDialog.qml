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

SaveAsDialogForm {
    id: root

    signal canceled()
    signal accepted()

    saveAsInput {
        onAccepted: okButton.clicked()
    }

    clearSaveAsInputButton {
        onClicked: {
            saveAsInput.text = ""
        }
    }

    cancelButton {
        onClicked: canceled()
    }

    okButton {
        onClicked: accepted()
    }

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            event.accepted = true
            cancelButton.clicked()
        }
    }
}
