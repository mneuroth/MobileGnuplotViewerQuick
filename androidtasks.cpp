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
#include <QtAndroid>
#include <QMessageBox>
#endif

#include "androidtasks.h"

QDateTime g_aCurrentReleaseDate( QDate(2015,12,31), QTime(17,00,00) );

//*************************************************************************

bool HasAccessToSDCardPath()
{
#if defined(Q_OS_ANDROID)
    QtAndroid::PermissionResult result = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    return result == QtAndroid::PermissionResult::Granted;
#else
    return true;
#endif
}

bool GrantAccessToSDCardPath(QObject * parent)
{
#if defined(Q_OS_ANDROID)
    Q_UNUSED(parent)
    QStringList permissions;
    permissions.append("android.permission.WRITE_EXTERNAL_STORAGE");
    QtAndroid::PermissionResultMap result = QtAndroid::requestPermissionsSync(permissions);
    if( result.count()!=1 && result["android.permission.WRITE_EXTERNAL_STORAGE"]!=QtAndroid::PermissionResult::Granted )
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
    bool bForce = true; //false;

    if( pDateForReplace!=0 )
    {
        if( QFile::exists(sOutputFileName) )
        {
            QFileInfo aOutputFile(sOutputFileName);

            // force replace of file if last modification date of existing file is older than the given date
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
            aFileOut.open(QIODevice::WriteOnly);
            aFileOut.write(aContent);
            if( bExecuteFlags )
            {
                aFileOut.setPermissions(QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser|aFileOut.permissions());
            }
            aFileOut.close();

            return true;
        }
        return false;
    }
    return true;    // file already existed !
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
    QString sCpuArchitecture(QSysInfo::buildCpuArchitecture());
    sAsset = QString(ASSETS_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_EXE);
    sOutput = QString(FILES_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_EXE);
    /*bool ok =*/ extractAssetFile(sAsset,sOutput,true,&aUpdateTimeStamp);
    // unpack beta version only for commerical version...
    sAsset = QString(ASSETS_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_BETA_EXE);
    sOutput = QString(FILES_DIR)+sCpuArchitecture+QDir::separator()+QString(GNUPLOT_BETA_EXE);
    /*bool ok =*/ extractAssetFile(sAsset,sOutput,true,&aUpdateTimeStamp);
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
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT2_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT2_GPT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT3_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT3_GPT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT4_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT4_GPT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT5_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT5_GPT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(SCRIPT6_GPT);
    sOutput = QString(SCRIPTS_DIR)+QString(SCRIPT6_GPT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
    sAsset = QString(ASSETS_SCRIPTS_DIR)+QString(DATA2_DAT);
    sOutput = QString(SCRIPTS_DIR)+QString(DATA2_DAT);
    extractAssetFile(sAsset,sOutput,false,&aUpdateTimeStamp);
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
    m_pUnpackThread = new UnpackFilesThread( this );
    connect(m_pUnpackThread,SIGNAL(finished()),this,SLOT(sltUnpackFinished()));
    m_pUnpackThread->start();
}

void AndroidTasks::sltUnpackFinished()
{
    if( m_pUnpackThread )
    {
        delete m_pUnpackThread;
        m_pUnpackThread = 0;
    }
}
