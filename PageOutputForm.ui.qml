import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Page {
    width: 600
    height: 400
    property alias btnGraphics: btnGraphics
    property alias btnHelp: btnHelp
    property alias btnInput: btnInput
    property alias btnSaveAs: btnSaveAs
    property alias btnClear: btnClear
    property alias btnShare: btnShare
    property alias txtOutput: txtOutput

    property string fontName: "Courier"

    anchors.fill: parent
    title: qsTr("Output")

    Label {
        id: lblOutput
        text: qsTr("Output")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    ScrollView {
        id: scrollView
        anchors.top: lblOutput.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextArea {
            id: txtOutput
            anchors.fill: parent
            font.family: fontName
            anchors.top: lblOutput.bottom
            placeholderText: qsTr("Text Area")
            readOnly: true
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: 95
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        rows: 2
        columns: 3

        Button {
            id: btnShare
            text: qsTr("Share")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnClear
            text: qsTr("Clear")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnSaveAs
            text: qsTr("Save as")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnInput
            text: qsTr("Input")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnHelp
            text: qsTr("Help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnGraphics
            text: qsTr("Graphics")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
