/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#include <QThread>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>
#if defined(Q_OS_ANDROID)
#if QT_VERSION < 0x060000
#include <QtAndroid>
#else
// see: https://www.qt.io/blog/qt-extras-modules-in-qt-6
#include <QCoreApplication>
//#include <QtCore/6.2.3/QtCore/private/qandroidextras_p.h>
#endif
#include <QMessageBox>
#endif

#include <QDebug>

#include "androidtasks.h"

QDateTime g_aCurrentReleaseDate( QDate(2021,1,11), QTime(7,00,00) );        // should be short date in future, to give some time for google play release

//*************************************************************************
/*
bool HasAccessToSDCardPath()
{
#if defined(Q_OS_ANDROID)
#if QT_VERSION < 0x060000
    QtAndroid::PermissionResult result = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    return result == QtAndroid::PermissionResult::Granted;
#else
    QFuture<QtAndroidPrivate::PermissionResult> result = QtAndroidPrivate::checkPermission(QtAndroidPrivate::PermissionType::Storage);
    return result.result() == QtAndroidPrivate::PermissionResult::Authorized;
#endif
#else
    return true;
#endif
}
*/
bool GrantAccessToSDCardPath(QObject * parent)
{
#if defined(Q_OS_ANDROID)
    Q_UNUSED(parent)
    QStringList permissions;
    permissions.append("android.permission.WRITE_EXTERNAL_STORAGE");
#if QT_VERSION < 0x060000
    QtAndroid::PermissionResultMap result = QtAndroid::requestPermissionsSync(permissions);
    if( result.count()!=1 && result["android.permission.WRITE_EXTERNAL_STORAGE"]!=QtAndroid::PermissionResult::Granted )
#else
#ifdef _WITH_STORAGE_ACCESS
    QFuture<QtAndroidPrivate::PermissionResult> result = QtAndroidPrivate::requestPermission(QtAndroidPrivate::PermissionType::Storage);
    if( result.result()!=QtAndroidPrivate::PermissionResult::Authorized )
#endif
#endif
    {
        //QMessageBox::warning(parent, QObject::tr("Access rights problem"), QObject::tr("Can not access the path to the external storage, please enable rights in settings for this application!"));
        return false;
    }
#else
    Q_UNUSED(parent)
#endif
    return true;
}

bool extractAssetFile(const QString & sAssetFileName, const QString & sOutputFileName, bool bExecuteFlags, QDateTime * pDateForReplace = 0)
{
#if defined(Q_OS_ANDROID)
    bool bForce = false;

    //qDebug() << "extractAssetFile " << sAssetFileName << " --> " << sOutputFileName << " execute=" << bExecuteFlags << " date=" << pDateForReplace << endl;
    if( pDateForReplace!=0 )
    {
        if( QFile::exists(sOutputFileName) )
        {
            QFileInfo aOutputFile(sOutputFileName);

            // force replace of file if last modification date of existing file is older than the given date
            // Remark: date of from asset extracted file is the time of installation !!!
            bForce = aOutputFile.lastModified() < *pDateForReplace;
        }
    }
    if( bForce || !QFile::exists(sOutputFileName) )
    {
        QFile aFile(sAssetFileName);
        if( aFile.open(QIODevice::ReadOnly) )
        {
            QByteArray aContent = aFile.readAll();
            aFile.close();

            QFileInfo aFileInfo(sOutputFileName);
            QString sPath = aFileInfo.absoluteDir().absolutePath();
            QDir aDir(sPath);
            aDir.mkpath(sPath);

            QFile aFileOut(sOutputFileName);
            bool ok = aFileOut.open(QIODevice::WriteOnly | QIODevice::Truncate);  // allow overwrite of existing files
            if( ok )
            {
                aFileOut.write(aContent);
                if( bExecuteFlags )
                {
                    /*bool ok =*/ aFileOut.setPermissions(QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser|QFile::ReadOwner|QFile::ReadUser|QFile::ReadOther|QFile::ReadGroup|QFile::WriteOwner|QFile::WriteUser|QFile::WriteOther|QFile::WriteGroup|aFileOut.permissions());
                }
                aFileOut.close();
                //QFile::setPermissions(sOutputFileName, QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser|QFile::permissions(sOutputFileName));
                return true;
            }
            else
            {
                qDebug() << "Error overwriting file " << sOutputFileName << Qt::endl;
                return false;
            }
        }
        return false;
    }
    return true;    // file already existed !
#else
    return false;
#endif
}

//*************************************************************************

class UnpackFilesThread : public QThread
{
public:
    UnpackFilesThread(QObject * pTarget);

    virtual void run();

private:
    QObject *  m_pTarget;
};

//*************************************************************************
/*
void PostProgressValue(QObject * pTarget, int & value, int increment)
{
    if( pTarget )
    {
        QEvent * pEvent = new UpdateProgressDlgEvent( value );
        QApplication::postEvent(pTarget,pEvent,Qt::LowEventPriority);
    }
    value += increment;
}
*/
void UnpackFiles(QObject * /*pProgress*/)
{
    QDateTime aUpdateTimeStamp = g_aCurrentReleaseDate;  // creation time of new gnuplot version 5.0.1

    // extract the gnuplot binary and help file to call gnuplot as external process
    QString sAsset,sOutput;
    //QString sGnuplot,sGnuplot_beta;
    QString sCpuArchitecture(QSysInfo::buildCpuArchitecture());
//    sAsset = QString(ASSETS_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_EXE);
//    sOutput = QString(FILES_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_EXE);
    //sGnuplot = sOutput;
//    /*bool ok =*/ extractAssetFile(sAsset,sOutput,true,&aUpdateTimeStamp);
    // unpack beta version only for commerical version...
//    sAsset = QString(ASSETS_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_BETA_EXE);
//    sOutput = QString(FILES_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_BETA_EXE);
    //sGnuplot_beta = sOutput;
//    /*bool ok =*/ extractAssetFile(sAsset,sOutput,true,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_DIR)+QString(GNUPLOT_GIH);
    sOutput = QString(FILES_DIR)+QString(GNUPLOT_GIH);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_DIR)+QString(GNUPLOT_COPYRIGHT);
    sOutput = QString(FILES_DIR)+QString(GNUPLOT_COPYRIGHT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    //sAsset = QString(ASSETS_DIR)+QString(EMPTY_SVG);
    //sOutput = QString(FILES_DIR)+QString(EMPTY_SVG);
    //extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_DIR)+QString(FAQ_TXT);
    sOutput = QString(FILES_DIR)+QString(FAQ_TXT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_DIR)+QString(GNUPLOTVIEWER_LICENSE);
    sOutput = QString(FILES_DIR)+QString(GNUPLOTVIEWER_LICENSE);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    // example scripts...
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT1_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT1_GPT);
    extractAssetFile(sAsset,sOutput,false);                         // do not overwrite existing (and maybe modified) example files !
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT2_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT2_GPT);
    extractAssetFile(sAsset,sOutput,false);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT3_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT3_GPT);
    extractAssetFile(sAsset,sOutput,false);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT4_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT4_GPT);
    extractAssetFile(sAsset,sOutput,false);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT5_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT5_GPT);
    extractAssetFile(sAsset,sOutput,false);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT6_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT6_GPT);
    extractAssetFile(sAsset,sOutput,false);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(DATA2_DAT);
    sOutput = QString(SCRIPTS_DIR)+QString(DATA2_DAT);
    extractAssetFile(sAsset,sOutput,false);
/*
    QString sOutputFileName = "/data/data/de.mneuroth.gnuplotviewerquick/lib/arm64-v8a/libgnuplot_android.so";
    QString sOutputFileName2 = "/data/data/de.mneuroth.gnuplotviewerquick/lib/arm64-v8a/libgnuplot_android_beta.so";

    bool copyok1 = QFile::copy(sGnuplot, sOutputFileName);
    bool copyok2 = QFile::copy(sGnuplot_beta, sOutputFileName2);
qDebug() << "COPY: " << copyok1 << " " << copyok2 << endl;
qDebug() << "src: " << sGnuplot << endl;
qDebug() << "tag: " << sOutputFileName << endl;
qDebug() << "src: " << sGnuplot_beta << endl;
qDebug() << "tag: " << sOutputFileName2 << endl;

    bool ok1 = QFile::setPermissions(sOutputFileName, QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser|QFile::permissions(sOutputFileName));
    bool ok2 = QFile::setPermissions(sOutputFileName2, QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser|QFile::permissions(sOutputFileName2));
    qDebug() << "XTRACTING gnuplot " << ok1 << " " << ok2 << endl;

    qDebug() << "existing target gnuplot " << QFile::exists(sOutputFileName) << " " << QFile::exists(sOutputFileName2) << endl;
    qDebug() << "existing source gnuplot " << QFile::exists(sGnuplot) << " " << QFile::exists(sGnuplot_beta) << endl;
*/
}

UnpackFilesThread::UnpackFilesThread(QObject * pTarget)
    : m_pTarget( pTarget )
{
}

void UnpackFilesThread::run()
{
    UnpackFiles( m_pTarget );
}

AndroidTasks::AndroidTasks()
    : m_pUnpackThread(0)
{
}

AndroidTasks::~AndroidTasks()
{
    if( m_pUnpackThread!=0 )
    {
        delete m_pUnpackThread;
    }
}

void AndroidTasks::Init()
{
#if defined(Q_OS_ANDROID)
    m_pUnpackThread = new UnpackFilesThread( this );
    connect(m_pUnpackThread,SIGNAL(finished()),this,SLOT(sltUnpackFinished()));
    m_pUnpackThread->start();
#elif defined(Q_OS_WASM)
    QDir aDir("/");
    aDir.mkpath("/scripts");
    QFile::copy(":/gnuplot.gih", "/gnuplot.gih");
    QFile::copy(":/gnuplot_copyright", "/gnuplot_copyright");
    QFile::copy(":/faq.txt", "/faq.txt");
    QFile::copy(":/gnuplotviewer_license.txt", "/gnuplotviewer_license.txt");
    QFile::copy(":/default.gpt", "/default.gpt");
    QFile::copy(":/butterfly.gpt", "/butterfly.gpt");
    QFile::copy(":/multiplot.gpt", "/multiplot.gpt");
    QFile::copy(":/splot.gpt", "/splot.gpt");
    QFile::copy(":/fitdata.gpt", "/fitdata.gpt");
    QFile::copy(":/data.dat", "/data.dat");
    QFile::copy(":/data.dat", "/scripts/data.dat");
#else
#endif
}

void AndroidTasks::sltUnpackFinished()
{
    if( m_pUnpackThread )
    {
        delete m_pUnpackThread;
        m_pUnpackThread = 0;
    }
}
