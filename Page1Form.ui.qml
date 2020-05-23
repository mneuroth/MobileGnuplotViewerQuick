import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    //width: 600
    //height: 400

    title: qsTr("Page 1")

    Label {
        text: qsTr("You are on Page 1.")
        anchors.centerIn: parent
    }

    TextArea {
        id: textArea
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.fill: parent
        placeholderText: qsTr("Text Area")
        width: parent.width - 10
        height: parent.height - 10
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:92;anchors_y:69}
}
##^##*/
