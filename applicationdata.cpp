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
#include "gnuplotsyntaxhighlighter.h"

#if defined(Q_OS_ANDROID)
#include "android/androidshareutils.hpp"
#include <QtAndroidExtras>
#endif

#include <QDir>
#include <QUrl>
#include <QFile>
#include <QBuffer>
#include <QByteArray>
#include <QTextStream>
#include <QStandardPaths>
#include <QImage>
#include <QSvgRenderer>
#include <QPainter>
#include <QtPrintSupport/QPrinter>
#include <QPdfWriter>
#include <QTextDocument>
#include <QTextCursor>
#include <QFileDialog>
#include <QQuickTextDocument>
#include <QTextDocument>

ApplicationData::ApplicationData(QObject *parent, ShareUtils * pShareUtils, StorageAccess & aStorageAccess, QQmlApplicationEngine & aEngine)
    : QObject(parent),
      m_aStorageAccess(aStorageAccess),
      m_pShareUtils(0),
      m_pTextDoc(0),
      m_pSyntaxHighlighter(0),
      m_aEngine(aEngine),
      m_bUseLocalFileDialog(false),
      m_bIsAdmin(false)
{
    m_pShareUtils = pShareUtils;
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
    delete m_pSyntaxHighlighter;
}

QString ApplicationData::getAppInfos() const
{
    return QString("Qt_")+qVersion()+" Platform: "+QSysInfo::buildAbi();
}

void ApplicationData::initDone()
{
    QObject* homePage = childObject<QObject*>(m_aEngine, "homePage", "");
    if( homePage!=0 )
    {
        QMetaObject::invokeMethod(homePage, "initDone", QGenericReturnArgument());
    }
}

bool ApplicationData::isAppStoreSupported() const
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return true;
#else
    return false;
#endif
}

bool ApplicationData::isShareSupported() const
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return true;
#else
    return false;
#endif
}

bool ApplicationData::isAndroid() const
{
#if defined(Q_OS_ANDROID)
    return true;
#else
    return false;
#endif
}

bool ApplicationData::isWASM() const
{
#if defined(Q_OS_WASM)
    return true;
#else
    return false;
#endif
}

bool ApplicationData::isMobileGnuplotViewerInstalled() const
{
    return m_pShareUtils != 0 ? m_pShareUtils->isMobileGnuplotViewerInstalled() : false;
}


bool ApplicationData::isUseLocalFileDialog() const
{
    return m_bUseLocalFileDialog;
}

void ApplicationData::setUseLocalFileDialog(bool value)
{
    if( m_bUseLocalFileDialog != value )
    {
        m_bUseLocalFileDialog = value;
        emit isUseLocalFileDialogChanged();
    }
}

bool ApplicationData::isAdmin() const
{
    return m_bIsAdmin;
}

void ApplicationData::setAdmin(bool value)
{
    if( m_bIsAdmin != value )
    {
        m_bIsAdmin = value;
        emit isAdminChanged();
    }
}

bool ApplicationData::isAppInstalled(const QString & sAppName) const
{
    return m_pShareUtils != 0 ? m_pShareUtils->isAppInstalled(sAppName) : false;
}

bool ApplicationData::setSyntaxHighlighting(bool enable)
{
    if( m_pTextDoc!=0 )
    {
        if( m_pSyntaxHighlighter!=0 )
        {
            if( !enable )
            {
                m_pSyntaxHighlighter->setDocument(0);
                delete m_pSyntaxHighlighter;
                m_pSyntaxHighlighter = 0;
                return true;
            }
            else
            {
                // nothing to do ! syntax highlighter already available
                return false;
            }
        }

        if(enable)
        {
            // this call invokes a onTextChanged for the textArea !
            m_pSyntaxHighlighter = new GnuplotSyntaxHighlighter(m_pTextDoc->textDocument());
            m_pSyntaxHighlighter->rehighlight();

            // simulate update of text to rehighlight text again
            QTextDocument * pDoc = m_pTextDoc->textDocument();
            QString txt = pDoc->toPlainText();
            pDoc->setPlainText("");
            pDoc->setPlainText(txt);

            return true;
        }
        else
        {
            return false;
        }
    }

}

int ApplicationData::findText(const QString & searchText, int iSearchStartPos, bool bForward, bool bMatchWholeWord, bool bCaseSensitive, bool bRegExpr)
{
    if( m_pTextDoc!=0 )
    {
        QTextDocument * pDoc = m_pTextDoc->textDocument();
        QTextDocument::FindFlags flags;
        if(  !bForward )
        {
            flags |= QTextDocument::FindBackward;
        }
        if( bMatchWholeWord )
        {
            flags |= QTextDocument::FindWholeWords;
        }
        if( bCaseSensitive )
        {
            flags |= QTextDocument::FindCaseSensitively;
        }
        QTextCursor cursor = pDoc->find(searchText, iSearchStartPos, flags);
        if( cursor.position()>=0 )
        {
            return cursor.position() - searchText.length();
        }
    }
    return -1;
}

QString ApplicationData::getOnlyFileName(const QString & url) const
{
    QUrl aUrl(url);
    QString name = aUrl.fileName();
    return name;
}

QString ApplicationData::getLocalPathWithoutFileName(const QString & url) const
{
    QUrl aUrl(url);
    QString localFile = aUrl.toLocalFile();
    QFileInfo aInfo(localFile);
    return aInfo.absolutePath();
}

QString ApplicationData::getNormalizedPath(const QString & path) const
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
    QString translatedFileName = fileName;
    if( IsAndroidStorageFileUrl(fileName) )
    {
        // handle android storage urls --> forward content://... to QFile directly
        translatedFileName = fileName;
    }
    else
    {
        if(!fileName.startsWith(":"))       // files with : should be resolved in the resources ...
        {
            QUrl url(fileName);
            if(url.isValid() && url.isLocalFile())
            {
                translatedFileName = url.toLocalFile();
            }
        }
    }
    return translatedFileName;
}


bool ApplicationData::simpleReadFileContent(const QString & fileName, QString & content)
{
    QFile file(fileName);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        content = "";
        return false;
    }

    QTextStream stream(&file);
    content = stream.readAll();

    file.close();

    return true;
}

bool ApplicationData::simpleWriteFileContent(const QString & fileName, const QString & content)
{
    QFile file(fileName);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        return false;
    }

    QTextStream stream(&file);
    stream << content;

    file.close();

    return true;
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
            return QString(READ_ERROR_OUTPUT);
        }
    }
    else
    {
        QString content;
        bool ok = simpleReadFileContent(translatedFileName, content);
        if( ok )
        {
            return content;
        }
        else
        {
            return QString(READ_ERROR_OUTPUT);
        }
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
        return simpleWriteFileContent(translatedFileName, content);
    }
}

bool ApplicationData::deleteFile(const QString & fileName)
{
    QFile aDir(fileName);
    bool ok = aDir.remove();
    return ok;
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
#elif defined(Q_OS_WASM)
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
    return "..\\gnuplotviewerquick\\files\\scripts";
#elif defined(Q_OS_MACOS)
    return "../gnuplotviewerquick/files/scripts";
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

#if defined(Q_OS_ANDROID)
static inline QString GetAbsolutePath(const QAndroidJniObject &file)
{
    QAndroidJniObject path = file.callObjectMethod("getAbsolutePath",
                                                   "()Ljava/lang/String;");
    if (!path.isValid())
        return QString();

    return path.toString();
}
#endif

static QStringList GetOriginalExternalFilesDirs(/*const char *directoryField = 0*/)
{
    QStringList result;

#if defined(Q_OS_ANDROID)
    QAndroidJniObject appCtx = QtAndroid::androidContext();
    if (!appCtx.isValid())
        return QStringList();

    QAndroidJniObject dirField = QAndroidJniObject::fromString(QLatin1String(""));
/*
    if (directoryField) {
        dirField = QJNIObjectPrivate::getStaticObjectField("android/os/Environment",
                                                           directoryField,
                                                           "Ljava/lang/String;");
        if (!dirField.isValid())
            return QStringList();
    }
*/
    QAndroidJniObject files = appCtx.callObjectMethod("getExternalFilesDirs",
                                                     "(Ljava/lang/String;)[Ljava/io/File;",
                                                     dirField.object());

    if (!files.isValid())
        return QStringList();

    QAndroidJniEnvironment env;

    // Converts the QAndroidJniObject into a jobjectArray
    jobjectArray arr = files.object<jobjectArray>();
    int size = env->GetArrayLength(arr);

    /* Loop that converts all the elements in the jobjectArray
     * into QStrings and puts them in a QStringList*/
    for (int i = 0; i < size; i++)
    {
        jobject file = env->GetObjectArrayElement(arr, i);

        QAndroidJniObject afile(file);
        result.append(GetAbsolutePath(afile));

        env->DeleteLocalRef(file);
    }

    //env->DeleteLocalRef(arr);
#else
    // nothing to do...
#endif

    return result;
}

static QString RemoveAppPath(const QString & item)
{
    int iFound = item.indexOf("/Android/data");
    if(iFound>=0)
    {
        return item.left(iFound);
    }
    return item;
}

static QStringList GetExternalFilesDirs(/*const char *directoryField = 0*/)
{
    QStringList result = GetOriginalExternalFilesDirs();
    QStringList newResult;

    foreach(const QString & item, result)
    {
        newResult.append(RemoveAppPath(item));
    }

    return newResult;
}

static QString GetSDCardPathOrg()
{
#if defined(Q_OS_ANDROID)
    // TODO --> this code does not work for sd cards on Android 6.0 and above, waiting for Qt 5.8 or 5.9
    // see: https://qt-project.org/forums/viewthread/35519
    QAndroidJniObject aMediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
        // maybe better: getExternalFilesDir(s)() or getExternalCacheDirs()
    QAndroidJniObject aMediaPath = aMediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    QString sSdCardAbsPath = aMediaPath.toString();
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck())
    {
        // Handle exception here.
        env->ExceptionClear();
        sSdCardAbsPath = SDCARD_DIRECTORY;
    }
    // other option may be: getenv("EXTERNAL_STORAGE")
    return sSdCardAbsPath;
#else
    return SDCARD_DIRECTORY;
#endif
}

QStringList ApplicationData::getSDCardPaths() const
{
    QStringList allPaths;
    allPaths.append(SDCARD_DIRECTORY);
    allPaths.append(GetExternalFilesDirs());
#if defined(Q_OS_WIN)
    // for testing...
    allPaths.append("c:\\tmp");
#endif    
    QString path = GetSDCardPathOrg();
    if(!allPaths.contains(path))
    {
        allPaths.append(path);
    }
#if defined(Q_OS_ANDROID)
    if( QDir(OLD_GNUPLOTVIEWER_SCRIPTS_DIR).exists() )
    {
        allPaths.append(OLD_GNUPLOTVIEWER_SCRIPTS_DIR);
    }
    if( QDir(OLD_GNUPLOTVIEWERFREE_SCRIPTS_DIR).exists() )
    {
        allPaths.append(OLD_GNUPLOTVIEWERFREE_SCRIPTS_DIR);
    }
#endif
    return allPaths;
}

QString ApplicationData::getDefaultScript() const
{
    return DEFAULT_SCRIPT;
}

QString ApplicationData::getErrorContent() const
{
    return READ_ERROR_OUTPUT;
}

bool ApplicationData::shareSimpleText(const QString & text)
{
    if( m_pShareUtils != 0 )
    {
        m_pShareUtils->share(text, QUrl());
        return true;
    }
    return false;
}

bool ApplicationData::shareText(const QString & tempFileName, const QString & text)
{
    return writeAndSendSharedFile(tempFileName, "", "text/plain", [this, text](QString name) -> bool { return this->saveTextFile(name, text); });
}

bool ApplicationData::shareImage(const QImage & image)
{
    return writeAndSendSharedFile("gnuplot_image.png", "", "image/png", [image](QString name) -> bool
    {
        return image.save(name);
    });
}

bool ApplicationData::saveDataAsPngImage(const QString & sUrlFileName, const QByteArray & data, int resolutionX, int resolutionY)
{
    QString translatedFileName = GetTranslatedFileName(sUrlFileName);

    QSvgRenderer aRenderer(data);
    QImage aImg(resolutionX, resolutionY, QImage::Format_ARGB32);

    aImg.fill(0xFFFFFFFF);  // white background

    // Get QPainter that paints to the image
    QPainter painter(&aImg);
    aRenderer.render(&painter);

    if( IsAndroidStorageFileUrl(translatedFileName) )
    {
        QByteArray aArr;
        QBuffer aBuffer(&aArr);
        aBuffer.open(QIODevice::WriteOnly);
        aImg.save(&aBuffer, "PNG");
        return m_aStorageAccess.updateFile(translatedFileName, aArr);
    }
    else
    {
        // Save, image format based on file extension
        QString sFileName = translatedFileName;
        // if original file name was no url, than use original file name (used for sharing files)
        //if( sFileName.isEmpty() )
        //{
        //    sFileName = sUrlFileName;
        //}
        return aImg.save(sFileName);
    }
}

bool ApplicationData::shareSvgData(const QVariant & data, int resolutionX, int resolutionY)
{
    return writeAndSendSharedFile("gnuplot_image.png", "", "image/png", [this, data, resolutionX, resolutionY](QString name) -> bool
    {
        QByteArray arrData = qvariant_cast<QByteArray>(data);
        return saveDataAsPngImage(name, arrData, resolutionX, resolutionY);
    });
}

bool ApplicationData::shareViewSvgData(const QVariant & data, int resolutionX, int resolutionY)
{
    return writeAndSendSharedFile("gnuplot_image.png", "", "image/png", [this, data, resolutionX, resolutionY](QString name) -> bool
    {
        QByteArray arrData = qvariant_cast<QByteArray>(data);
        return saveDataAsPngImage(name, arrData, resolutionX, resolutionY);
    }, false);
}

// https://stackoverflow.com/questions/33654060/create-pdf-document-for-printing-in-qt-from-template
// other possibility: QPdfWriter aPdfWriter("gnuplot_print.pdf");
void ApplicationData::writePdfFile(const QString & filename, const QString & text)
{
#if defined(Q_OS_IOS)
#else
    QPrinter printer(QPrinter::PrinterResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setPaperSize(QPrinter::A4);
    printer.setOutputFileName(filename);
    printer.setPageMargins(QMarginsF(30, 30, 30, 30));

//    QString sFont("Arial");   // "Times New Roman"
#if defined(Q_OS_ANDROID)
    QString sFont("Droid Sans Mono");
#else
    QString sFont("Courier");
#endif

    QFont headerFont(sFont, 8);
    QFont titleFont(sFont, 14, QFont::Bold);

    QTextCharFormat txtformat = QTextCharFormat();

    QTextDocument doc;
    doc.setPageSize(printer.pageRect().size());

    QTextCursor* cursor = new QTextCursor(&doc);

    txtformat.setFont(headerFont);
    cursor->insertText(text, txtformat);

    //cursor->movePosition(QTextCursor::Right /*&& QTextCursor::EndOfLine*/, QTextCursor::KeepAnchor, 1000);
    //cursor->insertText("currDate()", txtformat);

    doc.print(&printer);
#endif
}

bool ApplicationData::shareTextAsPdf(const QString & text, bool bSendFile)
{
    return writeAndSendSharedFile("gnuplot_text.pdf", "", "application/pdf", [this, text](QString name) -> bool
    {
        writePdfFile(name, text);
        return true;
    }, bSendFile);
}

void ApplicationData::logText(const QString & text)
{
    AddToLog(text);
}

void ApplicationData::getOpenFileContentAsync(const QString & nameFilter)
{
    auto fileContentReady = [this](const QString &fileName, const QByteArray &fileContent) {
         if (fileName.isEmpty()) {
             // No file was selected
         } else {
             // Use fileName and fileContent
             emit this->receiveOpenFileContent(fileName, fileContent);
         }
     };

    QFileDialog::getOpenFileContent(nameFilter, fileContentReady);
}

void ApplicationData::saveFileContentAsync(const QByteArray &fileContent, const QString &fileNameHint)
{
    QFileDialog::saveFileContent(fileContent, fileNameHint);
}

bool ApplicationData::writeAndSendSharedFile(const QString & fileName, const QString & fileExtension, const QString & fileMimeType, std::function<bool(QString)> saveFunc, bool bSendFile)
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
    if( bSendFile )
    {
        m_pShareUtils->sendFile(tempTargetX, tr("Send file"), fileMimeType, requestId, altImpl);
    }
    else
    {
        m_pShareUtils->viewFile(tempTargetX, tr("View file"), fileMimeType, requestId, altImpl);
    }

    // remark: remove temporary files in slot:  sltShareFinished() / sltShareError()
    return true;
#else
    Q_UNUSED(fileName)
    Q_UNUSED(fileExtension)
    Q_UNUSED(fileMimeType)
    Q_UNUSED(saveFunc)
    Q_UNUSED(bSendFile)
    return false;
#endif
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

//TODO DEBUGGING:    AddToLog("URL received "+sUrl);

    /*bool ok =*/ loadAndShowFileContent(sUrl);
}

void ApplicationData::sltFileReceivedAndSaved(const QString & sUrl)
{
    // <== share from google documents
    // --> /data/user/0/de.mneuroth.gnuplotviewerquick/files/gnuplotviewer_shared_files/Test.txt.txt

//TODO DEBUGGING:    AddToLog("URL file received "+sUrl);

    /*bool ok =*/ loadAndShowFileContent(sUrl);
}

void ApplicationData::sltShareError(int requestCode, const QString & message)
{
    Q_UNUSED(requestCode);
    Q_UNUSED(message);

    sltErrorText("Error sharing: received "+message);

    removeAllFilesForShare();
}

void ApplicationData::sltShareNoAppAvailable(int requestCode)
{
    Q_UNUSED(requestCode);

    sltErrorText("Error sharing: no app available");

    removeAllFilesForShare();
}

void ApplicationData::sltShareEditDone(int requestCode, const QString & urlTxt)
{
    Q_UNUSED(requestCode);
    Q_UNUSED(urlTxt);

    removeAllFilesForShare();
}

void ApplicationData::sltShareFinished(int requestCode)
{
    Q_UNUSED(requestCode);

    removeAllFilesForShare();
}

void ApplicationData::sltErrorText(const QString & msg)
{
    setOutputText(msg);
}

#if defined(Q_OS_ANDROID)
void ApplicationData::sltApplicationStateChanged(Qt::ApplicationState applicationState)
{
    if( applicationState == Qt::ApplicationState::ApplicationSuspended )
    {
        QObject* homePage = childObject<QObject*>(m_aEngine, "homePage", "");
        if( homePage!=0 )
        {
            QMetaObject::invokeMethod(homePage, "checkForModified", QGenericReturnArgument());
        }
    }
}
#endif

bool ApplicationData::loadAndShowFileContent(const QString & sFileName)
{
    bool ok = false;

    if( !sFileName.isEmpty() )
    {
        // autosave current file if needed
//        checkForModified(); // --> will be done when app is left

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
// TODO hier ggf. direkt signale an QML senden anstatt JavaScript methode aufrufen !!!???
            setScriptText(sScript);
            setScriptName(sFileName);
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
                Q_ARG(QVariant, sScript));
    }
}

void ApplicationData::setScriptName(const QString & sName)
{
    QObject* homePage = childObject<QObject*>(m_aEngine, "homePage", "");
    if( homePage!=0 )
    {
        QMetaObject::invokeMethod(homePage, "setScriptName",
                QGenericReturnArgument(),
                Q_ARG(QVariant, sName));
    }
}

void ApplicationData::setOutputText(const QString & sText)
{
    QObject* homePage = childObject<QObject*>(m_aEngine, "outputPage", "");
    if( homePage!=0 )
    {
        QMetaObject::invokeMethod(homePage, "setOutputText",
                QGenericReturnArgument(),
                Q_ARG(QVariant, sText));
    }
}

void ApplicationData::setTextDocument(QQuickTextDocument * pDoc)
{
    m_pTextDoc = pDoc;
}
