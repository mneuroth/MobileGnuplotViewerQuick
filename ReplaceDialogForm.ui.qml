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
    property alias clearfindWhatInputButton: clearfindWhatInputButton
    property alias clearReplaceWithInputButton: clearReplaceWithInputButton
    property alias replaceButton: replaceButton
    property alias replaceAllButton: replaceAllButton
    property alias findWhatInput: findWhatInput
    property alias replaceWithInput: replaceWithInput
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

            columns: 4
            rows: 6

            // ***** row 0

            Label {
                id: findLabel
                text: qsTr("Find what:")
                Layout.row: 0
                Layout.column: 0
            }

            TextField {
                id: findWhatInput
                //editable: true
                //model: findWhatModel
                focus: true

                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.row: 0
                Layout.column: 1

                //font.pixelSize: 12
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            Button {
                id: clearfindWhatInputButton
                text: "X"

                Layout.columnSpan: 1
                Layout.row: 0
                Layout.column: 3
                Layout.maximumWidth: 0.1*parent.width
            }

            // ***** row 1

            Label {
                id: replaceLabel
                text: qsTr("Replace with:")
                Layout.row: 1
                Layout.column: 0
            }

            TextField {
                id: replaceWithInput
                //editable: true
                //model: findWhatModel
                focus: true

                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.row: 1
                Layout.column: 1

                //font.pixelSize: 12
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            Button {
                id: clearReplaceWithInputButton
                text: "X"

                Layout.columnSpan: 1
                Layout.row: 1
                Layout.column: 3
                Layout.maximumWidth: 0.1*parent.width
            }

            // ***** row 2

            CheckBox {
                id: matchWholeWordCheckBox
                Layout.columnSpan: 3
                Layout.row: 2
                Layout.column: 0
                text: qsTr("Match whole word only")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 3

            CheckBox {
                id: caseSensitiveCheckBox
                Layout.columnSpan: 3
                Layout.row: 3
                Layout.column: 0
                text: qsTr("Case sensitive")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 4

            CheckBox {
                id: regularExpressionCheckBox
                visible: false
                Layout.columnSpan: 3
                Layout.row: 4
                Layout.column: 0
                text: qsTr("Regular expression")
                Keys.onEscapePressed: cancelButton.clicked()
                Keys.onBackPressed: cancelButton.clicked()
            }

            // ***** row 5

            Flow {

                Layout.columnSpan: 4
                Layout.row: 5
                Layout.column: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10

                Button {
                    id: findNextButton
                    text: qsTr("Find Next")
                    //highlighted: true
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }

                Button {
                    id: replaceButton
                    text: qsTr("Replace")
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }

                Button {
                    id: replaceAllButton
                    text: qsTr("Replace All")
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }

                Button {
                    id: cancelButton
                    text: qsTr("Close")
                    Keys.onEscapePressed: cancelButton.clicked()
                    Keys.onBackPressed: cancelButton.clicked()
                }
            }

            // ***** row 9
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.5;height:480;width:640}
}
##^##*/

