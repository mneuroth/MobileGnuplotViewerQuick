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

#include <QDir>

GnuplotInvoker::GnuplotInvoker()
{
    connect(&m_aGnuplotProcess,SIGNAL(finished(int,QProcess::ExitStatus)),this,SLOT(sltFinishedGnuplot(int,QProcess::ExitStatus)));
    connect(&m_aGnuplotProcess,SIGNAL(errorOccurred(QProcess::ProcessError)),this,SLOT(sltErrorGnuplot(QProcess::ProcessError)));
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
//            ui->svgGnuplotOutput->load(m_aLastGnuplotResult);
            emit sigResultReady(m_aLastGnuplotResult);

            //QString errText = m_aGnuplotProcess.readAllStandardError();
            //if( errText.length()==0 )
            //{
//                errText = tr("running ")+ui->lblSaveName->text()+" "+tr("ok")+"\n";
            //}
//            ui->txtErrors->setPlainText(ui->txtErrors->toPlainText()+errText);
//            ui->txtErrors->moveCursor(QTextCursor::End);
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
    QByteArray errorMsg = m_aGnuplotProcess.readAllStandardError();
    sltErrorText(tr("Error: gnuplot exited with error: code=%1 msg=%2 err=%3\ncode=%4 status=%5\nerrorMsg=%6\n").arg(error).arg(QString(errorMsg)).arg(m_aGnuplotProcess.error()).arg(m_aGnuplotProcess.exitCode()).arg(m_aGnuplotProcess.exitStatus()).arg(m_aGnuplotProcess.errorString()));
}

void GnuplotInvoker::sltRunGnuplot()
{
//    sltSwitchToGraphics();  // switch automatically to graphics output
//    QString sScript = ui->txtGnuplotInput->toPlainText();
//    runGnuplot(sScript);
//    if( ui->btnExport )
//    {
//        ui->btnExport->setEnabled(true);
//    }
}

void GnuplotInvoker::sltErrorText(const QString & sTxt)
{
//    ui->txtErrors->setPlainText(ui->txtErrors->toPlainText()+sTxt+"\n");
//    ui->txtErrors->moveCursor(QTextCursor::End);
//    sltSwitchToErrors();
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


void GnuplotInvoker::runGnuplot(const QString & sScript)
{
    // handle automatical clear of output (if selected)
//    if( ui->actionClear_output->isChecked() )
//    {
//        ui->txtErrors->clear();
//    }
    bool useVersionBeta = true; //ui->actionGnuplot_UseGnuplotBeta->isChecked();
#if defined(Q_OS_ANDROID)
    // ggf. GNUTERM setzen...
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QString sHelpFile = QString(FILES_DIR)+QString(GNUPLOT_GIH);
    env.insert("GNUHELP",sHelpFile);
    m_aGnuplotProcess.setProcessEnvironment(env);

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
#else
    m_aGnuplotProcess.start("/usr/local/bin/gnuplot"/*, QStringList() << "-c"*/);
#endif

    if (!m_aGnuplotProcess.waitForStarted())
    {
        sltErrorText(tr("Error: gnuplot not found!"));
        return;
    }

// TODO --> Aufloesung der Ausgabearea beachten !
    // create gnuplot script
    //QWindow * pWindow = windowHandle();
    //double logRes = pWindow->screen()->logicalDotsPerInch();
    //double physRes = pWindow->screen()->physicalDotsPerInch();
    //qDebug() << "RES: " << logRes << " " << physRes << endl;

//    QString sInput = QString("set term svg size %1,%2 fsize 16 dynamic\n").arg(ui->svgGnuplotOutput->width()/2).arg(ui->svgGnuplotOutput->height()/2)
//    QString sInput = QString("set term svg size %1,%2 dynamic font \"courier,16\"\n").arg(512).arg(512)
    QString sInput = QString("set term svg size %1,%2 dynamic font \"Mono,28\"\n").arg(1024).arg(1024)
    //QString sInput = QString("set term svg dynamic font \"Mono\"\n").arg(1024).arg(1024)
                        + sScript
                        + QString("\nexit\n");

    // write script to stdinput for gnuplot process
    m_aGnuplotProcess.write(sInput.toUtf8()/*.toLatin1()*/);
    m_aGnuplotProcess.closeWriteChannel();
}
