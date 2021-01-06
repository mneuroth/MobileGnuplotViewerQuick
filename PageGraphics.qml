/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/
import QtQuick 2.9
import QtQuick.Controls 2.2

PageGraphicsForm {

    imageMouseArea {
        // see: photosurface.qml
        onWheel: {
            if (wheel.modifiers & Qt.ControlModifier) {
                image.rotation += wheel.angleDelta.y / 120 * 5;
                if (Math.abs(photoFrame.rotation) < 4)
                    image.rotation = 0;
            } else {
                image.rotation += wheel.angleDelta.x / 120;
                if (Math.abs(image.rotation) < 0.6)
                    image.rotation = 0;
                var scaleBefore = image.scale;
                image.scale += image.scale * wheel.angleDelta.y / 120 / 10;
            }
        }
        onDoubleClicked: {
            // set to default with double click
            image.scale = 1.0
            image.x = 5
            image.y = 5
        }
    }

    btnOutput {
        onClicked: {
            stackView.pop()
            stackView.push(outputPage)
        }
    }

    btnHelp {
        onClicked: {
            stackView.pop()
            stackView.push(helpPage)
        }
    }

    btnInput {
        onClicked: {
            //stackView.push(homePage)
            stackView.pop()
        }
    }
}
