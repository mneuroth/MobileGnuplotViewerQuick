import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    property alias image: image

    //width: 600
    //height: 400
    title: qsTr("Graphics")

    Image {
        id: image
        x: 5
        y: 5
        anchors.fill: parent
        source: "spaceship.svg"
        fillMode: Image.PreserveAspectFit
        // TODO: https://forum.qt.io/topic/112192/zooming-an-svg-image
        MouseArea {
            anchors.fill: parent
            onClicked: image.scale *= 2
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1;anchors_height:100;anchors_width:100;anchors_x:59;anchors_y:119}
}
##^##*/

