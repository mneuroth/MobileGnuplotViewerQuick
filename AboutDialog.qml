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
import QtQuick.Dialogs 1.2

AboutDialogForm {

    lblAppInfos {
        text: applicationData.getAppInfos()
    }

    btnClose {
        onClicked:  {
            stackView.pop()
        }
    }
}
