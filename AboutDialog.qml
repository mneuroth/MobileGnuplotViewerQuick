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

    lblGithubPage {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    btnClose {
        onClicked:  {
            stackView.pop()
        }
    }

    Keys.onReleased: (event) => {
        console.log("ABOUT Key "+event.key)
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            event.accepted = true
            bntClose.clicked()
        }
    }
}
