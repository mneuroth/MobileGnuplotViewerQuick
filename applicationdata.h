/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#ifndef APPLICATIONDATA_H
#define APPLICATIONDATA_H

#include <QObject>
#include <QQmlApplicationEngine>

class ShareUtils;
class StorageAccess;

void AddToLog(const QString & msg);

// **************************************************************************

// see: https://stackoverflow.com/questions/14791360/qt5-syntax-highlighting-in-qml
template <class T> T childObject(QQmlApplicationEngine& engine,
                                 const QString& objectName,
                                 const QString& propertyName)
{
    QList<QObject*> rootObjects = engine.rootObjects();
    foreach (QObject* object, rootObjects)
    {
        QObject* child = object->findChild<QObject*>(objectName);
        if (child != 0)
        {
            if( propertyName.length()==0 )
            {
                return dynamic_cast<T>(object);
            }
            else
            {
                std::string s = propertyName.toStdString();
                QObject* object = child->property(s.c_str()).value<QObject*>();
                Q_ASSERT(object != 0);
                T prop = dynamic_cast<T>(object);
                Q_ASSERT(prop != 0);
                return prop;
            }
        }
    }
    return (T) 0;
}

// **************************************************************************

class ApplicationData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filesPath READ getFilesPath)
    Q_PROPERTY(QString homePath READ getHomePath)
    Q_PROPERTY(QString sdCardPath READ getSDCardPath)
    Q_PROPERTY(QString defaultScript READ getDefaultScript)
    Q_PROPERTY(QString appInfos READ getAppInfos)
    Q_PROPERTY(bool isAppStoreSupported READ isAppStoreSupported NOTIFY isAppStoreSupportedChanged)
    Q_PROPERTY(bool isShareSupported READ isShareSupported NOTIFY isShareSupportedChanged)
    Q_PROPERTY(bool isAndroid READ isAndroid NOTIFY isAndroidChanged)
    Q_PROPERTY(bool isWASM READ isWASM NOTIFY isWASMChanged)
    Q_PROPERTY(bool isMobileGnuplotViewerInstalled READ isMobileGnuplotViewerInstalled NOTIFY isMobileGnuplotViewerInstalledChanged)

public:
    explicit ApplicationData(QObject *parent, ShareUtils * pShareUtils, StorageAccess & aStorageAccess, QQmlApplicationEngine & aEngine);
    ~ApplicationData();

    Q_INVOKABLE QString getAppInfos() const;

    Q_INVOKABLE void initDone();       

    Q_INVOKABLE QString getOnlyFileName(const QString & url) const;
    Q_INVOKABLE QString getNormalizedPath(const QString & path) const;
    Q_INVOKABLE QString getLocalPathWithoutFileName(const QString & url) const;

    Q_INVOKABLE QString readFileContent(const QString & fileName) const;
    Q_INVOKABLE bool writeFileContent(const QString & fileName, const QString & content);

    Q_INVOKABLE bool deleteFile(const QString & fileName);

    Q_INVOKABLE bool hasAccessToSDCardPath() const;
    Q_INVOKABLE bool grantAccessToSDCardPath(QObject * parent);

    Q_INVOKABLE bool shareSimpleText(const QString & text);
    Q_INVOKABLE bool shareText(const QString & tempFileName, const QString & text);
    Q_INVOKABLE bool shareImage(const QImage & image);
    Q_INVOKABLE bool shareSvgData(const QVariant & data);
    Q_INVOKABLE bool shareViewSvgData(const QVariant & data);
    Q_INVOKABLE bool shareTextAsPdf(const QString & text, bool bSendFile);

    Q_INVOKABLE void writePdfFile(const QString & sFileName, const QString & text);
    Q_INVOKABLE bool saveDataAsPngImage(const QString & sUrlFileName, const QByteArray & data);

    Q_INVOKABLE bool isAppInstalled(const QString & sAppName) const;

    // for debugging only
    Q_INVOKABLE void logText(const QString & text);

    // for WASM only
    Q_INVOKABLE void getOpenFileContentAsync(const QString & nameFilter);
    Q_INVOKABLE void saveFileContentAsync(const QByteArray &fileContent, const QString &fileNameHint = QString());

    Q_INVOKABLE QStringList getSDCardPaths() const;
    QString getSDCardPath() const;
    QString getFilesPath() const;
    QString getHomePath() const;

    QString getDefaultScript() const;

    void setScriptText(const QString & sScript);
    void setScriptName(const QString & sName);
    void setOutputText(const QString & sText);

    static QString simpleReadFileContent(const QString & fileName);
    static bool simpleWriteFileContent(const QString & fileName, const QString & content);

    bool isAppStoreSupported() const;
    bool isShareSupported() const;
    bool isAndroid() const;
    bool isWASM() const;

    bool isMobileGnuplotViewerInstalled() const;

signals:
    // for testing only
    void sendDummyData(const QString & txt, int value);

    void isAppStoreSupportedChanged();
    void isShareSupportedChanged();
    void isAndroidChanged();
    void isWASMChanged();
    void isMobileGnuplotViewerInstalledChanged();

    void receiveOpenFileContent(const QString & fileName, const QByteArray & fileContent);

public slots:
    void sltFileUrlReceived(const QString & sUrl);
    void sltFileReceivedAndSaved(const QString & sUrl);
    void sltShareError(int requestCode, const QString & message);
    void sltShareEditDone(int requestCode, const QString & urlTxt);
    void sltShareFinished(int requestCode);
    void sltShareNoAppAvailable(int requestCode);

    void sltErrorText(const QString & msg);

#if defined(Q_OS_ANDROID)
     void sltApplicationStateChanged(Qt::ApplicationState applicationState);
#endif

private:
    bool writeAndSendSharedFile(const QString & fileName, const QString & fileExtension, const QString & fileMimeType, std::function<bool(QString)> saveFunc, bool bSendFile = true);
    void removeAllFilesForShare();
    bool loadAndShowFileContent(const QString & sFileName);
    bool loadTextFile(const QString & sFileName, QString & sText);
    bool saveTextFile(const QString & sFileName, const QString & sText);

#if defined(Q_OS_ANDROID)
    QStringList                 m_aSharedFilesList;
#endif
    StorageAccess &             m_aStorageAccess;
    ShareUtils *                m_pShareUtils;      // not an owner !

    QQmlApplicationEngine &     m_aEngine;          // not an owner !
};

#endif // APPLICATIONDATA_H
