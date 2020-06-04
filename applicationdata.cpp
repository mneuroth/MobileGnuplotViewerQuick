/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#include "applicationdata.h"
#include "androidtasks.h"
#include "shareutils.hpp"
#include "storageaccess.h"

#if defined(Q_OS_ANDROID)
#include "android/androidshareutils.hpp"
#endif

#include <QDir>
#include <QUrl>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QImage>

ApplicationData::ApplicationData(QObject *parent, ShareUtils * pShareUtils, StorageAccess & aStorageAccess, QQmlApplicationEngine & aEngine)
    : QObject(parent),
      m_aStorageAccess(aStorageAccess),
      m_aEngine(aEngine)
{
    m_pShareUtils = pShareUtils; //new ShareUtils(this);
#if defined(Q_OS_ANDROID)
    QMetaObject::Connection result;
    result = connect(m_pShareUtils, SIGNAL(fileUrlReceived(QString)), this, SLOT(sltFileUrlReceived(QString)));
    result = connect(m_pShareUtils, SIGNAL(fileReceivedAndSaved(QString)), this, SLOT(sltFileReceivedAndSaved(QString)));
    result = connect(m_pShareUtils, SIGNAL(shareError(int, QString)), this, SLOT(sltShareError(int, QString)));
    connect(m_pShareUtils, SIGNAL(shareFinished(int)), this, SLOT(sltShareFinished(int)));
    connect(m_pShareUtils, SIGNAL(shareEditDone(int, QString)), this, SLOT(sltShareEditDone(int, QString)));
    connect(m_pShareUtils, SIGNAL(shareNoAppAvailable(int)), this, SLOT(sltShareNoAppAvailable(int)));
#endif
}

ApplicationData::~ApplicationData()
{
#if defined(Q_OS_ANDROID)
    //delete m_pShareUtils;
#endif
}


QString ApplicationData::normalizePath(const QString & path) const
{
    QDir aInfo(path);
    return aInfo.canonicalPath();
}

bool IsAndroidStorageFileUrl(const QString & url)
{
    return url.startsWith("content:/");
}

QString GetTranslatedFileName(const QString & fileName)
{
    QUrl url(fileName);
    QString translatedFileName(url.toLocalFile());
    if( IsAndroidStorageFileUrl(fileName) )
    {
        // handle android storage urls --> forward content://... to QFile directly
        translatedFileName = fileName;
    }
    return translatedFileName;
}

QString ApplicationData::readFileContent(const QString & fileName) const
{
    QString translatedFileName = GetTranslatedFileName(fileName);

    if( IsAndroidStorageFileUrl(translatedFileName) )
    {
        QByteArray data;
        bool ok = m_aStorageAccess.readFile(translatedFileName, data);
        if( ok )
        {
            return QString(data);
        }
        else
        {
            return QString(tr("Error reading ") + fileName);
        }
    }
    else
    {
        QFile file(translatedFileName);

        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            return QString(tr("Error reading ") + fileName);
        }

        QTextStream stream(&file);
        auto text = stream.readAll();

        file.close();

        return text;
    }
}

bool ApplicationData::writeFileContent(const QString & fileName, const QString & content)
{
    QString translatedFileName = GetTranslatedFileName(fileName);

    if( IsAndroidStorageFileUrl(translatedFileName) )
    {
        bool ok = m_aStorageAccess.updateFile(translatedFileName, content.toUtf8());
        return ok;
    }
    else
    {
        QFile file(translatedFileName);

        if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            return false;
        }

        QTextStream stream(&file);
        stream << content;

        file.close();

        return true;
    }
}

bool ApplicationData::hasAccessToSDCardPath() const
{
    return ::HasAccessToSDCardPath();
}

bool ApplicationData::grantAccessToSDCardPath(QObject * parent)
{
    return ::GrantAccessToSDCardPath(parent);
}

QString ApplicationData::getFilesPath() const
{
#if defined(Q_OS_ANDROID)
    return FILES_DIR;
#elif defined(Q_OS_WINDOWS)
    return FILES_DIR;
#else
    return ".";
#endif
}

QString ApplicationData::getHomePath() const
{
#if defined(Q_OS_ANDROID)
    return SCRIPTS_DIR;
#elif defined(Q_OS_WINDOWS)
    return "c:\\tmp";
#else
    return ".";
#endif
}

QString ApplicationData::getSDCardPath() const
{
#if defined(Q_OS_ANDROID)
// TODO: list of sdcards returning: internal & external SD Card
    return "/sdcard"; // FILES_DIR;
#elif defined(Q_OS_WIN)
    return "g:\\";
#else
    return "/sdcard";
#endif
}

bool ApplicationData::shareSimpleText(const QString & text)
{
    m_pShareUtils->share(text, QUrl());
    return true;
}

bool ApplicationData::shareText(const QString & text, const QString & fileName)
{
    return writeAndSendSharedFile(fileName, "", "text/plain", [this, text](QString name) -> bool { return this->saveTextFile(name, text); });
}

bool ApplicationData::shareImage(const QImage & image)
{
    return writeAndSendSharedFile("gnuplot_image.png", ".png", "image/png", [image](QString name) -> bool
    {
        return image.save(name);
    });
}

void ApplicationData::logText(const QString & text)
{
    AddToLog(text);
}

void ApplicationData::test()
{
    emit sendDummyData("hallo welt", 42);
}

QString ApplicationData::dumpDirectoryContent(const QString & path) const
{
    QDir aDir(path);
    QStringList aList = aDir.entryList();
    return path + " --> \n" +aList.join(";\n") + "\n";
}

bool ApplicationData::writeAndSendSharedFile(const QString & fileName, const QString & fileExtension, const QString & fileMimeType, std::function<bool(QString)> saveFunc)
{
#if defined(Q_OS_ANDROID)
    QString fileNameIn = fileName;
    if(fileNameIn.isNull() || fileNameIn.isEmpty())
    {
        fileNameIn = "default.gpt";
    }
    QStringList paths = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation);
    QString targetPath = paths[0]+QDir::separator()+"temp_shared_files";
    QString targetPathX = paths[0]+QDir::separator()+"gnuplotviewer_shared_files";
    QString tempTarget = targetPath+QDir::separator()+fileNameIn+fileExtension;
    QString tempTargetX = targetPathX+QDir::separator()+fileNameIn+fileExtension;
    if( !QDir(targetPath).exists() )
    {
        if( !QDir("").mkpath(targetPath) )
        {
            return false;
        }
    }
    QFile::remove(tempTarget);
    // write temporary file with current script content
    if( !saveFunc(tempTarget) )
    {
        return false;
    }

    QFile::remove(tempTargetX);
    if( !QFile::copy(tempTarget, tempTargetX) )
    {
        return false;
    }

    m_aSharedFilesList.append(tempTarget);
    m_aSharedFilesList.append(tempTargetX);

    /*bool permissionsSet =*/ QFile(tempTargetX).setPermissions(QFileDevice::ReadUser | QFileDevice::WriteUser);
    int requestId = 24;
    bool altImpl = false;
    m_pShareUtils->sendFile(tempTargetX, tr("Send file"), fileMimeType, requestId, altImpl);

    // remark: remove temporary files in slot:  sltShareFinished() / sltShareError()
#endif
    return true;
}

void ApplicationData::removeAllFilesForShare()
{
#if defined(Q_OS_ANDROID)
    // remove temporary copied file for sendFile ==> maybe erase the whole directory for data exchange ?
    foreach(const QString & name, m_aSharedFilesList)
    {
        QFile::remove(name);
    }

    m_aSharedFilesList.clear();
#endif
}


void ApplicationData::sltFileUrlReceived(const QString & sUrl)
{
    // <== share from file manager
    // --> /storage/0000-0000/Texte/xyz.txt     --> SD-Card
    // --> /storage/emulated/0/Texte/xyz.txt    --> internal Memory

    // output:
    // /data/user/0/de.mneuroth.gnuplotviewerquick/files
    // /storage/emulated/0/Android/data/de.mneuroth.gnuplotviewerquick/files

    sltErrorText("URL received "+sUrl);

    bool ok = loadAndShowFileContent(sUrl);
}

void ApplicationData::sltFileReceivedAndSaved(const QString & sUrl)
{
    // <== share from google documents
    // --> /data/user/0/de.mneuroth.gnuplotviewerquick/files/gnuplotviewer_shared_files/Test.txt.txt

    sltErrorText("URL file received "+sUrl);

    bool ok = loadAndShowFileContent(sUrl);
}

void ApplicationData::sltShareError(int requestCode, const QString & message)
{
    Q_UNUSED(requestCode);
    Q_UNUSED(message);

    sltErrorText("Error sharing received "+message);

    removeAllFilesForShare();
}

void ApplicationData::sltShareNoAppAvailable(int requestCode)
{
    Q_UNUSED(requestCode);

    sltErrorText("share no app");

    removeAllFilesForShare();
}

void ApplicationData::sltShareEditDone(int requestCode, const QString & urlTxt)
{
    Q_UNUSED(requestCode);
    Q_UNUSED(urlTxt);

    sltErrorText("share edit done");

    removeAllFilesForShare();
}

void ApplicationData::sltShareFinished(int requestCode)
{
    Q_UNUSED(requestCode);

    sltErrorText("share finished done");

    removeAllFilesForShare();
}

void ApplicationData::sltErrorText(const QString & msg)
{
    setScriptText(msg);
}

bool ApplicationData::loadAndShowFileContent(const QString & sFileName)
{
    bool ok = false;

    if( !sFileName.isEmpty() )
    {
        // autosave current file if needed
//        checkForModified();

        // load script and show it
        QFileInfo aFileInfo(sFileName);
        QString sScript;
        ok = loadTextFile(sFileName, sScript);
        if( !ok )
        {
            sltErrorText(tr("Can not load file %1").arg(sFileName));
        }
        else
        {
// TODO hier ggf. direkt signale an QML senden !!!
            setScriptText(sScript);
            setScriptName(sFileName);
//            ui->txtGnuplotInput->setPlainText(sScript);

            // update last used directory
//            m_sLastDirectory = aFileInfo.absoluteDir().absolutePath();

            // update save name text field
//            ui->lblSaveName->setText(aFileInfo.fileName()/*QString::fromUtf8(aFileInfo.fileName().toLatin1())*/);    // workaround
        }
    }
    else
    {
        sltErrorText(tr("File name is empty!"));
    }

    return ok;
}

bool ApplicationData::saveTextFile(const QString & sFileName, const QString & sText)
{
    bool ok = false;
    QFile aFile(sFileName.toUtf8());            // workaround
    if( aFile.open(QIODevice::WriteOnly) )
    {
        qint64 iCount = aFile.write(sText.toUtf8());    // write text as utf8 encoded text
        aFile.close();
        ok = iCount>=0;
//        m_sCurrentFileName = sFileName;
    }
    if( !ok )
    {
        sltErrorText(tr("Error writing file: ")+sFileName);
    }
    return ok;
}

bool ApplicationData::loadTextFile(const QString & sFileName, QString & sText)
{
    // TODO Maybe: hier muss ggf. der Zugriff auf die Datei sichergestellt werden !!! --> Intent.FLAG_GRANT_READ_URI_PERMISSION
    // WORKAROUND: einmalig auf SD-Karten-Speicher / Externen-Speicher zugreifen
    bool ok = false;
    QFile aFile(sFileName);
    if( aFile.open(QIODevice::ReadOnly) )
    {
        QByteArray aContent = aFile.readAll();
        aFile.close();
        sText = QString::fromUtf8(aContent);    // interpret file as utf8 encoded text
        ok = sText.length()>0;
//        m_sCurrentFileName = sFileName;
    }
    return ok;
}

void ApplicationData::setScriptText(const QString & sScript)
{
    QObject* homePage = childObject<QObject*>(m_aEngine, "homePage", "");
    if( homePage!=0 )
    {
        QMetaObject::invokeMethod(homePage, "setScriptText",
                QGenericReturnArgument(),
                Q_ARG(QString, sScript));
    }
}

void ApplicationData::setScriptName(const QString & sName)
{
    QObject* homePage = childObject<QObject*>(m_aEngine, "homePage", "");
    if( homePage!=0 )
    {
        QMetaObject::invokeMethod(homePage, "setScriptName",
                QGenericReturnArgument(),
                Q_ARG(QString, sName));
    }
}
