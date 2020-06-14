import QtQuick 2.4

Item {
    width: 400
    height: 400
    anchors.fill: parent

    Rectangle {
        id: rectangle
        color: "#ffffff"
        anchors.fill: parent

        Text {
            id: element
            x: 93
            y: 168
            text: qsTr("Support Page Text !")
            font.pixelSize: 12
        }
    }
}

/*##^##
Designer {
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:108;anchors_y:91}
}
##^##*/
