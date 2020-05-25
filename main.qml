import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2

import de.mneuroth.gnuplotinvoker 1.0

ApplicationWindow {
    id: window
    objectName: "window"
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }
    }

    Page1Form {
        id: graphicsPage
        objectName: "graphicsPage"
            imageMouseArea {
                onClicked: {
                    if(mouse.modifiers & Qt.ControlModifier) {
                        image.scale /= 1.25
                    }
                    else {
                        image.scale *= 1.25
                    }
                }
                onWheel: {
                    if (wheel.modifiers & Qt.ControlModifier) {
                        image.scale /= 1.5
                    } else {
                        image.scale *= 1.5
                    }
                }
        }
    }

    Page2Form {
        id: helpPage
        objectName: "helpPage"
    }

    HomeForm {
        id: homePage
        objectName: "homePage"

        btnOpen  {
            onClicked:  {
                console.log("open")
                fileDialog.open()
            }
        }

        btnRun {
            onClicked: {
                console.log("run")
                var s = gnuplotInvoker.run(homePage.textArea.text)
                //homePage.textArea.text = s
                graphicsPage.image.source = "data:image/svg+xml;utf8," + s
                stackView.push(graphicsPage)
            }
        }

        btnGraphics {
            onClicked: {
                console.log("graphics")
                stackView.push(graphicsPage)
            }
        }

        btnExit {
            onClicked: {
                onClicked: Qt.quit()
            }
        }
    }

    FileDialog {
        id: fileDialog
        visible: false
        modality: Qt.WindowModal
        title: "Choose a file"
        selectExisting: true
        selectMultiple: false
        selectFolder: false
        nameFilters: ["Image files (*.png *.jpg)", "All files (*)"]
        selectedNameFilter: "All files (*)"
        sidebarVisible: false
        onAccepted: {
              console.log("Accepted: " + fileUrls)
              homePage.textArea.text = "# Hello World !\nplot sin(x)"
              if (fileDialogOpenFiles.checked)
                  for (var i = 0; i < fileUrls.length; ++i)
                      Qt.openUrlExternally(fileUrls[i])
        }
        onRejected: { console.log("Rejected") }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Graphics")
                width: parent.width
                onClicked: {
                    stackView.push(graphicsPage)
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Help")
                width: parent.width
                onClicked: {
                    stackView.push(helpPage)
                    drawer.close()
                }
            }
        }
    }

    GnuplotInvoker {
        id: gnuplotInvoker
    }

    StackView {
        id: stackView
        initialItem: homePage
        anchors.fill: parent
        width: parent.width
        height: parent.height
    }
}
