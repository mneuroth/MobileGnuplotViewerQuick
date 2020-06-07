import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Page {
    id: page

    width: 600
    height: 400
    property alias btnOutput: btnOutput
    property alias btnInput: btnInput
    property alias btnRunHelp: btnRunHelp
    property alias txtHelp: txtHelp

    property string fontName: "Courier"

    anchors.fill: parent
    title: qsTr("Help")

    Label {
        id: lblHelp
        text: qsTr("Help")
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    ScrollView {
        id: scrollView
        anchors.top: lblHelp.bottom
        anchors.right: parent.right
        anchors.bottom: gridButtons.top
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextArea {
            id: txtHelp
            anchors.fill: parent
            font.family: fontName
            placeholderText: qsTr("Enter gnuplot help command here (e. g. help plot)\nand activate \"Run help\" button")
        }
    }

    GridLayout {
        id: gridButtons
        x: 44
        y: 5
        height: 50
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        rows: 1
        columns: 3

        Button {
            id: btnInput
            text: qsTr("Input")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnOutput
            text: qsTr("Output")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: btnRunHelp
            text: qsTr("Run help")
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
