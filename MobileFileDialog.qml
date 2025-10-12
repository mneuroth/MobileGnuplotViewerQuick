import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

MobileFileDialogForm {
    id: root

    /*
        This component needs an object with name applicationData which has this methods:
          - string getNormalizedPath(string fileName)
          - bool hasAccessToSDCardPath()
          - void grantAccessToSDCardPath()
    */

// TODO: allow sorting for: name, date, size -> radio button

    property string urlPrefix: "file://"

    property bool isSaveAsModus: false
    property bool isSaveACopyModus: false
    property bool isDeleteModus: false
    property bool isDirectoryModus: false
    property bool isSaveAsImage: false
    property bool isExtendedInfos: false
    property bool isStorageSupported: true     // TODO PATCH
    property bool isMobilePlatform: false
    property bool isAdminModus: false
    property string homePath: "."
    property var textControl: null
    property var pathsSDCard: []

    signal openSelectedFile(string fileName)
    signal saveSelectedFile(string fileName)
    signal deleteSelectedFile(string fileName)

    signal storageOpenFile()
    signal storageCreateFile(string fileName)

    signal accepted()
    signal rejected()

    listView {
        // https://stackoverflow.com/questions/9400002/qml-listview-selected-item-highlight-on-click
        currentIndex: -1
        focus: true
        onCurrentIndexChanged: {
            // update currently selected filename
            if( listView.currentItem !== null && listView.currentItem.isFile )
            {
                root.txtMFDInput.text = listView.currentItem.currentFileName
                root.setCurrentName(listView.currentItem.currentFileName)
            }
            else
            {
                root.txtMFDInput.text = ""
                root.setCurrentName("")
                //listView.currentItem.currentFileName("")
            }

            if( !root.isSaveAsModus )
            {
                root.btnOpen.enabled = listView.currentItem === null || listView.currentItem.isFile
            }
        }
    }

    function setAdminModus(value) {
        root.bIsAdminModus = value
        isAdminModus = value
    }

    function setSaveAsModus(bAsImage) {
        root.isSaveAsImage = bAsImage
        root.isSaveAsModus = true
        root.isSaveACopyModus = false
        root.isDeleteModus = false
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.bIsAdminModus = isAdminModus
        root.lblMFDInput.text = qsTr("new file name:")
        root.txtMFDInput.text = bAsImage ? qsTr("unknown.png") : qsTr("unknown.txt")
        root.txtMFDInput.readOnly = false
        root.btnOpen.text = qsTr("Save as")
        root.btnOpen.enabled = true
        root.btnStorage.enabled = true
    }

    function setOpenModus() {
        root.isSaveAsImage = false
        root.isSaveAsModus = false
        root.isSaveACopyModus = false
        root.isDeleteModus = false
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.bIsAdminModus = isAdminModus
        root.lblMFDInput.text = qsTr("open name:")
        root.txtMFDInput.readOnly = true
        root.btnOpen.text = qsTr("Open")
        root.btnOpen.enabled = false
        root.btnStorage.enabled = true
    }

    function setDeleteModus() {
        root.isSaveAsImage = false
        root.isSaveAsModus = false
        root.isSaveACopyModus = false
        root.isDeleteModus = true
        root.isDirectoryModus = false
        root.bShowFiles = true
        root.bIsAdminModus = isAdminModus
        root.lblMFDInput.text = qsTr("current file name:")
        root.txtMFDInput.text = ""
        root.txtMFDInput.readOnly = true
        root.btnOpen.text = qsTr("Delete")
        root.btnOpen.enabled = false
        root.btnStorage.enabled = false
    }

    function setDirectory(newPath) {
        newPath = applicationData.getNormalizedPath(newPath)
        listView.model.folder = buildValidUrl(newPath)
        listView.currentIndex = -1
        listView.focus = true
        lblDirectoryName.text = newPath
        currentDirectory = newPath
    }

    function setCurrentName(name) {
        currentFileName = name
    }

    function deleteCurrentFileNow() {
        var fullPath = currentDirectory + "/" + currentFileName
        deleteSelectedFile(fullPath)
        accepted()
    }

    function openCurrentFileNow() {
        var fullPath = currentDirectory + "/" + currentFileName
        openSelectedFile(fullPath)
        accepted()
    }

    function saveAsCurrentFileNow(fullPath) {
        saveSelectedFile(fullPath)
        accepted()
    }

    function navigateToDirectory(sdCardPath) {
        if( !applicationData.hasAccessToSDCardPath() )
        {
            applicationData.grantAccessToSDCardPath(/*window*/)
        }

        if( applicationData.hasAccessToSDCardPath() )
        {
            root.setDirectory(sdCardPath)
            root.setCurrentName("")
        }
    }

    function buildValidUrl(path) {
        // ignore call, if we already have a file:// url
        if( path.startsWith(urlPrefix) )
        {
            return path
        }
        // ignore call, if we try to access resouces from qrc --> path starting with :
        if( path.startsWith(":") )
        {
            return path
        }
        // ignore call, if we already have a content:// url (android storage framework)
        if( path.startsWith("content://") )
        {
            return path
        }

        var sAdd = path.startsWith("/") ? "" : "/"
        var sUrl = urlPrefix + sAdd + path
        return sUrl
    }

    function formatSize(fileSize) {
        var value = Math.round(fileSize/1024*10)/10
        if( value>=1000 ) {
            var valueMB = Math.round(fileSize/(1024*1024)*10)/10
            return valueMB + " MBytes"
        } else if( value>=1 ) {
            return value + " kBytes"
        } else {
            return fileSize + "  Bytes"
        }
    }

    Component {
        id: fileDelegate

        Rectangle {
            property string currentFileName: fileName
            property bool isFile: !fileIsDir
            height: 40
            color: "transparent"
            anchors.left: parent.left
            anchors.right: parent.right
            Keys.onPressed: {
                 if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if( fileIsDir )
                    {
                        root.setDirectory(filePath)
                        root.setCurrentName(fileName)
                        event.accepted = true
                    }
                    else
                    {
                        root.openCurrentFileNow()
                        event.accepted = true
                    }
                 }
            }

            GridLayout {
                anchors.fill: parent

                columns: 4

                Image {
                    id: itemIcon
                    source: fileIsDir ? "files/file96.svg" : "files/new104.svg"

                    Layout.row: 0
                    Layout.column: 0
                    Layout.maximumHeight: itemLabel.height
                    Layout.maximumWidth: itemLabel.height
                }
                Label {
                    id: itemLabel

                    verticalAlignment: Text.AlignVCenter
                    text: /*(fileIsDir ? "DIR_" : "FILE") + " | " +*/ fileName //+ " (" + fileModified + ")"

                    Layout.fillWidth: true
                    Layout.row: 0
                    Layout.column: 1
                }
                Label {
                    id: itemDate
                    visible: isExtendedInfos
                    font.pointSize: isMobilePlatform ? itemLabel.font.pointSize*0.75 : itemLabel.font.pointSize

                    verticalAlignment: Text.AlignVCenter
                    text: fileModified //fileModified.toLocaleString(Qt.locale(),Locale.ShortFormat)

                    Layout.row: 0
                    Layout.column: 2
                }
                Label {
                    id: itemSize
                    visible: isExtendedInfos
                    font.pointSize: isMobilePlatform ? itemLabel.font.pointSize*0.75 : itemLabel.font.pointSize

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: fileIsDir ? "" : formatSize(fileSize)

                    Layout.row: 0
                    Layout.column: 3
                    Layout.minimumWidth: parent.width*0.2  //(isMobilePlatform ? 0.2 : 0.2)
                }
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    root.listView.currentIndex = index
                    if( fileIsDir )
                    {
                        root.setDirectory(filePath)
                        root.setCurrentName(fileName)
                    }
                }
                onDoubleClicked: {
                    root.listView.currentIndex = index
                    if( !fileIsDir )
                    {
                        root.openCurrentFileNow()
                    }
                }
            }
        }
    }

    btnOpen  {
        onClicked: {
            console.log("open")
            if( root.isDeleteModus )
            {
                root.deleteCurrentFileNow()
            }
            else if( root.isDirectoryModus )
            {
                root.selectCurrentDirectoryNow()
            }
            else if( root.isSaveAsModus )
            {
                var fullPath = currentDirectory + "/" + txtMFDInput.text
                root.saveAsCurrentFileNow(fullPath)
            }
            else
            {
                root.openCurrentFileNow()
            }
        }
    }

    btnCancel {
        onClicked: rejected()
    }

    btnUp {
        onClicked: {
            // stop with moving up when home directory is reached
            if( root.bIsAdminModus || (applicationData.getNormalizedPath(currentDirectory) !== applicationData.getNormalizedPath(homePath)) )
            {
                root.setDirectory(currentDirectory + "/..")
                root.setCurrentName("")
                root.listView.currentIndex = -1
            }
        }
    }

    btnHome {
        onClicked: {
            root.setDirectory(homePath)
            root.setCurrentName("")
            root.listView.currentIndex = -1
        }
    }

    btnMySd {
        onClicked: {
            root.setDirectory("/sdcard")
            root.setCurrentName("")
            root.listView.currentIndex = -1
        }
    }

    Menu {
        id: menuSDCard
        Repeater {
                model: pathsSDCard
                MenuItem {
                    text: modelData
                    onTriggered: {
                        root.navigateToDirectory(modelData)
                    }
                }
        }
    }

    btnSDCard {
        enabled: pathsSDCard !== null && pathsSDCard.length>0
        onClicked: {
            menuSDCard.x = btnSDCard.x
            menuSDCard.y = btnSDCard.height
            menuSDCard.open()            
        }
    }

    btnStorage {
        visible: isStorageSupported
        onClicked: {
            if( root.isSaveAsModus )
            {
                storageCreateFile(root.txtMFDInput.text)
            }
            else
            {
                storageOpenFile()
            }
        }
    }
}
