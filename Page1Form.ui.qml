import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    property alias image: image
    property alias imageMouseArea: imageMouseArea

    //width: 600
    //height: 400
    title: qsTr("Graphics")

//    ScrollView {
//        id: scrollView
//        anchors.rightMargin: 5
//        anchors.leftMargin: 5
//        anchors.bottomMargin: 5
//        anchors.topMargin: 5
//        anchors.fill: parent

        Image {
            id: image
            x: 5
            y: 5
            width: parent.width
            height: parent.height
            objectName: "imageArea"
            // TODO: see: https://stackoverflow.com/questions/51059963/qml-how-to-load-svg-dom-into-an-image
            source: /*"DSC_4945.JPG"*/ "spaceship.svg"
            fillMode: Image.PreserveAspectFit
            // TODO: https://forum.qt.io/topic/112192/zooming-an-svg-image
            MouseArea {
                id: imageMouseArea
                anchors.fill: parent
            }
        }
//    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_x:5;anchors_y:5}D{i:1;anchors_height:200;anchors_width:200}
}
##^##*/

