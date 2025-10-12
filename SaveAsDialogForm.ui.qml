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

Page {
    id: root

    focusPolicy: Qt.StrongFocus
    focus: true

    anchors.fill: parent

    property alias cancelButton: cancelButton
    property alias okButton: okButton
    property alias clearSaveAsInputButton: clearSaveAsInputButton
    property alias saveAsInput: saveAsInput
    property alias grid: grid

    // remove standard Ok button from dialog (see: https://stackoverflow.com/questions/50858605/qml-dialog-removing-ok-button)
    /*contentItem:*/ Item {

        anchors.fill: parent

        GridLayout {
            id: grid

            anchors.fill: parent
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5

            columns: 3
            rows: 2

            // ***** row 0

            Label {
                id: saveAsLabel
                text: qsTr("Save as:")
                Layout.row: 0
                Layout.column: 0
            }

            TextField {
                id: saveAsInput
                //editable: true
                //model: findWhatModel
                focus: true

                Layout.columnSpan: 1
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 1

                //font.pixelSize: 12
            }

            Button {
                id: clearSaveAsInputButton
                text: "X"

                Layout.columnSpan: 1
                Layout.row: 0
                Layout.column: 2
                Layout.maximumWidth: 0.1*parent.width
            }

            Flow {

                Layout.columnSpan: 3
                Layout.row: 1
                Layout.column: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10

                Button {
                    id: okButton
                    //Layout.fillWidth: true
                    //Layout.row: 6
                    //Layout.column: 0
                    text: qsTr("Ok")
                    //highlighted: true
                    Layout.preferredWidth: defaultButtonWidth
                    Layout.preferredHeight: defaultButtonHeight                }

                Button {
                    id: cancelButton
                    //Layout.fillWidth: true
                    //width: findNextButton.width
                    //Layout.row: 6
                    //Layout.column: 2
                    text: qsTr("Cancel")
                    Layout.preferredWidth: defaultButtonWidth
                    Layout.preferredHeight: defaultButtonHeight
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.5;height:480;width:640}
}
##^##*/

