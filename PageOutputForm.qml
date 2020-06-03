import QtQuick 2.12
import QtQuick.Controls 2.5

Page {

    width: 600
    height: 400
    id: helpPage
    anchors.fill: parent
    title: qsTr("Output")

    Label {
        text: qsTr("You are on Output Page.")
        anchors.centerIn: parent
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

