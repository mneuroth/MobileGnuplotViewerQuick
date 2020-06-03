import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page

    width: 600
    height: 400
    property alias txtHelp: txtHelp
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

    TextArea {
        id: txtHelp
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.top: lblHelp.bottom
        anchors.topMargin: 5
        placeholderText: qsTr("Text Area")
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:41;anchors_y:61}
}
##^##*/

