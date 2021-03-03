/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#ifndef GNUPLOTINVOKER_H
#define GNUPLOTINVOKER_H

#include <QObject>

#if defined(Q_OS_IOS)
class QProcess {
public:
    enum ProcessError {
        Crashed,
        Timedout
    };

    enum ExitStatus {
        NormalExit,
        CrashExit
    };

    void waitForFinished() {
    }
    QString readAll() {
        return "";
    }
    QByteArray readAllStandardError() {
        return "";
    }
};
#else
#include <QProcess>
#endif

class GnuplotInvoker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ getLastError)
    Q_PROPERTY(bool useBeta READ getUseBeta WRITE setUseBeta)
    Q_PROPERTY(bool syncXandYResolution READ getSyncXandYResolution WRITE setSyncXandYResolution)
    Q_PROPERTY(int resolutionX READ getResolutionX WRITE setResolutionX)
    Q_PROPERTY(int resolutionY READ getResolutionY WRITE setResolutionY)
    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize)
    Q_PROPERTY(int invokeCount READ getInvokeCount WRITE setInvokeCount)

public:
    GnuplotInvoker();

    Q_INVOKABLE QString run(const QString & sCmd);

    QString getLastError() const;
    bool getUseBeta() const;
    void setUseBeta(bool value);
    bool getSyncXandYResolution() const;
    void setSyncXandYResolution(bool value);
    int  getResolutionX() const;
    void setResolutionX(int value);
    int  getResolutionY() const;
    void setResolutionY(int value);
    int  getFontSize() const;
    void setFontSize(int value);
    int  getInvokeCount() const;
    void setInvokeCount(int value);

signals:
    void sigResultReady(const QString & svgData);
    void sigShowErrorText(const QString & txt, bool bShowOutputPage = true);

public slots:
#ifndef _USE_BUILTIN_GNUPLOT
    void sltFinishedGnuplot(int exitCode, QProcess::ExitStatus exitStatus);
    void sltErrorGnuplot(QProcess::ProcessError error);
#endif
    void sltErrorText(const QString & sTxt);
    void sltErrorTextWithoutPageActivation(const QString & sTxt);

private:
    void handleGnuplotError(int exitCode);
    void runGnuplot(const QString & sScript);

    QString     m_aLastGnuplotResult;
    QString     m_aLastGnuplotError;
    bool        m_bUseBeta;
    bool        m_bSyncXandYResolution;
    int         m_iResolutionX;
    int         m_iResolutionY;
    int         m_iFontSize;
    int         m_iInvokeCount;
#ifndef _USE_BUILTIN_GNUPLOT
    QProcess    m_aGnuplotProcess;
#endif
};

#endif // GNUPLOTINVOKER_H
