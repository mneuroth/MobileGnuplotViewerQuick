import QtQuick 2.4

SupportDialogForm {

    btnSupportLevel0 {
        enabled: settings.supportLevel < 0
        onClicked: {
            supportLevel0.purchase()
        }
    }

    btnSupportLevel1 {
        enabled: settings.supportLevel < 1
        onClicked: {
            supportLevel1.purchase()
        }
    }

    btnSupportLevel2 {
        enabled: settings.supportLevel < 2
        onClicked: {
            supportLevel2.purchase()
        }
    }

    btnClose {
        onClicked:  {
            stackView.pop()
        }
    }
}
