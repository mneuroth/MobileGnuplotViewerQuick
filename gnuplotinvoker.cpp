/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#include "gnuplotinvoker.h"
#include "androidtasks.h"
#include "applicationdata.h"

#include <QDir>

GnuplotInvoker::GnuplotInvoker()
    : m_bUseBeta(false),
      m_iResolution(1024),
      m_iFontSize(28),
      m_iInvokeCount(0)
{
#if !defined(Q_OS_IOS)
    connect(&m_aGnuplotProcess,SIGNAL(finished(int,QProcess::ExitStatus)),this,SLOT(sltFinishedGnuplot(int,QProcess::ExitStatus)));
    connect(&m_aGnuplotProcess,SIGNAL(errorOccurred(QProcess::ProcessError)),this,SLOT(sltErrorGnuplot(QProcess::ProcessError)));
#endif
}

QString GnuplotInvoker::run(const QString & sCmd)
{
    m_aLastGnuplotError = "";
    m_aLastGnuplotResult = "";
    runGnuplot(sCmd);
    m_aGnuplotProcess.waitForFinished();

    return m_aLastGnuplotResult /*+ m_aLastGnuplotError*/;
}

QString GnuplotInvoker::getLastError() const
{
    return m_aLastGnuplotError;
}

bool GnuplotInvoker::getUseBeta() const
{
    return m_bUseBeta;
}

void GnuplotInvoker::setUseBeta(bool value)
{
    m_bUseBeta = value;
}

int GnuplotInvoker::getResolution() const
{
    return m_iResolution;
}

void GnuplotInvoker::setResolution(int value)
{
    m_iResolution = value;
}

int GnuplotInvoker::getFontSize() const
{
    return m_iFontSize;
}

void GnuplotInvoker::setFontSize(int value)
{
    m_iFontSize = value;
}

int GnuplotInvoker::getInvokeCount() const
{
    return m_iInvokeCount;
}

void GnuplotInvoker::setInvokeCount(int value)
{
    m_iInvokeCount = value;
}

void GnuplotInvoker::sltFinishedGnuplot(int exitCode, QProcess::ExitStatus exitStatus)
{
    if( exitStatus==QProcess::NormalExit)
    {
        // produce graphical output from returned svg graphics
        m_aLastGnuplotResult = m_aGnuplotProcess.readAll();
        m_aLastGnuplotError = m_aGnuplotProcess.readAllStandardError();
        // has the returned result a valid svg format ?
        if( QString(m_aLastGnuplotResult).startsWith(QString("<?xml")) )
        {
            emit sigResultReady(m_aLastGnuplotResult);
        }
        else
        {
            sltErrorText(m_aLastGnuplotError);
            handleGnuplotError(exitCode);
        }
    }
    else
    {
        handleGnuplotError(exitCode);
    }
}

void GnuplotInvoker::sltErrorGnuplot(QProcess::ProcessError error)
{
#if !defined(Q_OS_IOS)
    QByteArray errorMsg = m_aGnuplotProcess.readAllStandardError();
    sltErrorText(tr("Error: gnuplot exited with error: code=%1 msg=%2 err=%3\ncode=%4 status=%5\nerrorMsg=%6\n").arg(error).arg(QString(errorMsg)).arg(m_aGnuplotProcess.error()).arg(m_aGnuplotProcess.exitCode()).arg(m_aGnuplotProcess.exitStatus()).arg(m_aGnuplotProcess.errorString()));
#endif
}

void GnuplotInvoker::sltErrorText(const QString & sTxt)
{
    emit sigShowErrorText(sTxt);
}

void GnuplotInvoker::handleGnuplotError(int exitCode)
{
    QByteArray error = m_aGnuplotProcess.readAllStandardError();

    QString sError;
    if( exitCode!=0 )
    {
        sError = QString(tr("Error code=%1\n")).arg(exitCode);
    }
    sltErrorText(sError+QString(error));
}

extern "C" int gnu_main(int argc, char **argv);

#define TEMP_GNUPLOT_SCRIPT "./_temp_.gpt"
#define TEMP_GNUPLOT_OUTPUT "./_output_.svg"

void GnuplotInvoker::runGnuplot(const QString & sScript)
{
    m_iInvokeCount++;

#ifdef _USE_BUILTIN_GNUPLOT
    // see: http://gnuplot.respawned.com/
    // see: https://github.com/YasasviPeruvemba/gnuplot.js
    // see: https://www.it.iitb.ac.in/frg/wiki/images/c/ca/P1ProjectReport.pdf
    int argc = 2;
    char * argv[2];
    argv[0] = new char[512];
    strcpy(argv[0], "gnuplot");
    argv[1] = new char[512];
    strcpy(argv[1], TEMP_GNUPLOT_SCRIPT);

    QString sScriptContent = QString("set term svg size %1,%2 dynamic font \"Mono,%3\"\n").arg(m_iResolution).arg(m_iResolution).arg(m_iFontSize)
                        + QString("set output '%1'\n").arg(TEMP_GNUPLOT_OUTPUT)
                        + sScript
                        + QString("\nexit\n");

    ApplicationData::simpleWriteFileContent(argv[1], sScriptContent);

    int result = gnu_main(argc, argv);

    if( result==0 )
    {
        QString sResultContent = ApplicationData::simpleReadFileContent(TEMP_GNUPLOT_OUTPUT);
        if( QString(sResultContent).startsWith(QString("<?xml")) )
        {
            m_aLastGnuplotResult = sResultContent;
            emit sigResultReady(sResultContent);
        }
        else
        {
            sltErrorText(QString(tr("Warning: unexpected result running built-in gnuplot !")));
        }
    }
    else
    {
        sltErrorText(QString(tr("Error: executing built-in gnuplot ! return=%1")).arg(result));
    }

    delete [] argv[0];
    delete [] argv[1];

    // remove temporary files
    //QFile::remove(TEMP_GNUPLOT_SCRIPT);
    //QFile::remove(TEMP_GNUPLOT_OUTPUT);
#else
    bool useVersionBeta = getUseBeta();
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QString sHelpFile = QString(FILES_DIR)+QString(GNUPLOT_GIH);
    env.insert("GNUHELP",sHelpFile);
    m_aGnuplotProcess.setProcessEnvironment(env);

#if defined(Q_OS_ANDROID)
    // ggf. GNUTERM setzen...
    // start gnuplot process
    QString sCpuArchitecture(QSysInfo::buildCpuArchitecture());
    QString sGnuplotFile = QString(FILES_DIR)+sCpuArchitecture+QDir::separator()+QString(useVersionBeta ? GNUPLOT_BETA_EXE : GNUPLOT_EXE);
    m_aGnuplotProcess.start(sGnuplotFile);
#elif defined(Q_OS_WIN32)
    if( useVersionBeta )
    {
        m_aGnuplotProcess.start("C:\\Users\\micha\\Downloads\\gnuplot52\\gnuplot\\bin\\gnuplot.exe");
    }
    else
    {
        m_aGnuplotProcess.start("C:\\Users\\micha\\Downloads\\gp504-win32-mingw\\gnuplot\\bin\\gnuplot.exe");
    }
    //m_aGnuplotProcess.start("C:\\usr\\neurothmi\\install\\gp460win32\\gnuplot\\bin\\gnuplot.exe");
#elif defined(Q_OS_MACOS)
    m_aGnuplotProcess.start("/usr/local/bin/gnuplot"/*, QStringList() << "-c"*/);
#elif defined(Q_OS_WASM) || defined(Q_OS_IOS)
#error use built in gnuplot please
#else
    m_aGnuplotProcess.start("/usr/bin/gnuplot"/*, QStringList() << "-c"*/);
#endif

    if (!m_aGnuplotProcess.waitForStarted())
    {
        sltErrorText(QString(tr("Error: gnuplot not found ! path=%1")).arg(m_aGnuplotProcess.program()));
        return;
    }

    QString sInput = QString("set term svg size %1,%2 dynamic font \"Mono,%3\"\n").arg(m_iResolution).arg(m_iResolution).arg(m_iFontSize)
                        + sScript
                        + QString("\nexit\n");

    // write script to stdinput for gnuplot process
    m_aGnuplotProcess.write(sInput.toUtf8()/*.toLatin1()*/);
    m_aGnuplotProcess.closeWriteChannel();
#endif
}
