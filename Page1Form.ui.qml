import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    property alias image: image
    property alias imageMouseArea: imageMouseArea

    //width: 600
    //height: 400
    title: qsTr("Graphics")

    Image {
        id: image
        objectName: "imageArea"
        x: 5
        y: 5
        anchors.fill: parent
        // TODO: see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
        source: "spaceship.svg"
        fillMode: Image.PreserveAspectFit
        // TODO: https://forum.qt.io/topic/112192/zooming-an-svg-image
        MouseArea {
            id: imageMouseArea
            anchors.fill: parent
            onClicked: image.scale *= 2
        }
    }
}



