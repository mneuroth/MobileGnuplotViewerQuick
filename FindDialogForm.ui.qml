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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

Page {
    id: root

    focusPolicy: Qt.StrongFocus
    focus: true

    anchors.fill: parent

    property alias cancelButton: cancelButton
    property alias findNextButton: findNextButton
    property alias findWhatInput: findWhatInput
    property alias backwardDirection: backwardDirection
    property alias matchWholeWordCheckBox: matchWholeWordCheckBox
    property alias caseSensitiveCheckBox: caseSensitiveCheckBox
    property alias regularExpressionCheckBox: regularExpressionCheckBox
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
            rows: 8

            // ***** row 0

            Label {
                id: findLabel
                text: qsTr("Find what:")
                Layout.row: 0
                Layout.column: 0
            }

            Rectangle {
                color: "light yellow"
                border.color: "black"
                border.width: 1
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 1
                width: findWhatInput.width+10
                height: findWhatInput.height+10

                TextInput {
                    id: findWhatInput
                    //editable: true
                    //model: findWhatModel
                    focus: true
                    width: 2000
                    x: 5
                    y: 5

                    //font.pixelSize: 12
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }
            }

            // ***** row 1

            CheckBox {
                id: matchWholeWordCheckBox
                Layout.columnSpan: 2
                Layout.row: 1
                Layout.column: 0
                text: qsTr("Match whole word only")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 2

            CheckBox {
                id: caseSensitiveCheckBox
                Layout.columnSpan: 2
                Layout.row: 2
                Layout.column: 0
                text: qsTr("Case sensitive")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 3

            CheckBox {
                id: regularExpressionCheckBox
                Layout.columnSpan: 3
                Layout.row: 3
                Layout.column: 0
                text: qsTr("Regular expression")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 4

            CheckBox {
                id: backwardDirection
                Layout.columnSpan: 2
                Layout.row: 4
                Layout.column: 0
                text: qsTr("Search backward")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 5

            Flow {

                Layout.columnSpan: 3
                Layout.row: 5
                Layout.column: 0
                Layout.fillWidth: true

                spacing: 10

                Button {
                    id: findNextButton
                    //Layout.fillWidth: true
                    //Layout.row: 6
                    //Layout.column: 0
                    text: qsTr("&Find Next")
                    //highlighted: true
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }

                Button {
                    id: cancelButton
                    //Layout.fillWidth: true
                    //width: findNextButton.width
                    //Layout.row: 6
                    //Layout.column: 2
                    text: qsTr("Cancel")
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }

            }

            // ***** row 5

            // ***** row 6
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.5;height:480;width:640}
}
##^##*/

