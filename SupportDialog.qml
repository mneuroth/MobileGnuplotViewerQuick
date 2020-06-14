/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.5

SupportDialogForm {

    btnSupportLevel0 {
        enabled: settings.supportLevel < 0
        onClicked: {
            supportLevel0.purchase()
        }
    }

    btnSupportLevel1 {
        enabled: settings.supportLevel < 1
        onClicked: {
            supportLevel1.purchase()
        }
    }

    btnSupportLevel2 {
        enabled: settings.supportLevel < 2
        onClicked: {
            supportLevel2.purchase()
        }
    }

    btnClose {
        onClicked:  {
            stackView.pop()
        }
    }

    onVisibleChanged: {
        lblLevel0.text = qsTr("Status=") + supportLevel0.status
        lblLevel1.text = qsTr("Status=") + supportLevel1.status
        lblLevel2.text = qsTr("Status=") + supportLevel2.status
    }
}
