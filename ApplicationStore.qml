import QtQuick 2.0
import QtPurchasing 1.0

Store {
    id: store

    property alias supportLevel0: supportLevel0
    property alias supportLevel1: supportLevel1
    property alias supportLevel2: supportLevel2

    Product {
        id: supportLevel0
        identifier: "support_level_0"
        type: Product.Unlockable

        property bool purchasing: false

        onPurchaseSucceeded: {
            //showErrorDialog(qsTr("Purchase successfull."))
            settings.supportLevel = 0

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showErrorDialog(qsTr("Purchase not completed."))
            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseRestored: {
            //showErrorDialog(qsTr("Purchase restored."))
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

        property bool purchasing: false

        onPurchaseSucceeded: {
            settings.supportLevel = 1

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showErrorDialog(qsTr("Purchase not completed."))
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

        property bool purchasing: false


        onPurchaseSucceeded: {
            settings.supportLevel = 2

            transaction.finalize()

            // Reset purchasing flag
            purchasing = false
        }

        onPurchaseFailed: {
            showErrorDialog(qsTr("Purchase not completed."))
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

