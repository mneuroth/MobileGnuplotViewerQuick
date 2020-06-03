import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    width: 600
    height: 400
    property alias txtOutput: txtOutput
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

    TextArea {
        id: txtOutput
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.top: lblOutput.bottom
        anchors.topMargin: 5
        placeholderText: qsTr("Text Area")
        readOnly: true
    }
}
