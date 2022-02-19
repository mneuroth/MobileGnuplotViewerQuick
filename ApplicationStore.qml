// REMARK: this file is now obsolete, store and products are handled now in main.qml !

import QtQuick 2.0
//import QtPurchasing 1.0

import PicoTemplateApp 1.0

Item {



Store {
    id: store
}

Product {
    id: supportLevel0
    identifier: "support_level_0"
    type: Product.Unlockable
    store: store

    property bool purchasing: false

    onPurchaseSucceeded: {
        //showInfoDialog(qsTr("Purchase successfull."))
        settings.supportLevel = 0

        transaction.finalize()

        showThankYouDialog(settings.supportLevel)

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseFailed: {
        showInfoDialog(qsTr("Purchase not completed."))
        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseRestored: {
        //showInfoDialog(qsTr("Purchase restored."))
        settings.supportLevel = 0

        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }
}

Product {
    id: supportLevel1
    identifier: "support_level_1"
    type: Product.Unlockable
    store: store

    property bool purchasing: false

    onPurchaseSucceeded: {
        settings.supportLevel = 1

        transaction.finalize()

        showThankYouDialog(settings.supportLevel)

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseFailed: {
        showInfoDialog(qsTr("Purchase not completed."))
        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseRestored: {
        settings.supportLevel = 1

        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }
}

Product {
    id: supportLevel2
    identifier: "support_level_2"
    type: Product.Unlockable
    store: store

    property bool purchasing: false


    onPurchaseSucceeded: {
        settings.supportLevel = 2

        transaction.finalize()

        showThankYouDialog(settings.supportLevel)

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseFailed: {
        showInfoDialog(qsTr("Purchase not completed."))
        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }

    onPurchaseRestored: {
        settings.supportLevel = 2

        transaction.finalize()

        // Reset purchasing flag
        purchasing = false
    }
}

}
