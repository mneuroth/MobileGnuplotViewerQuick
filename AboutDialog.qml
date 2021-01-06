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
import QtQuick.Controls 2.1

AboutDialogForm {

    lblAppInfos {
        text: applicationData !== null ? applicationData.getAppInfos() : "?"
    }

    lblIconInfos {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblAppName {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    btnClose {
        onClicked:  {
            stackView.pop()
        }
    }
}
