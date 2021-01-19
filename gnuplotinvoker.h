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
    Q_PROPERTY(int resolution READ getResolution WRITE setResolution)
    Q_PROPERTY(int fontSize READ getFontSize WRITE setFontSize)
    Q_PROPERTY(int invokeCount READ getInvokeCount WRITE setInvokeCount)

public:
    GnuplotInvoker();

    Q_INVOKABLE QString run(const QString & sCmd);

    QString getLastError() const;
    bool getUseBeta() const;
    void setUseBeta(bool value);
    int  getResolution() const;
    void setResolution(int value);
    int  getFontSize() const;
    void setFontSize(int value);
    int  getInvokeCount() const;
    void setInvokeCount(int value);

signals:
    void sigResultReady(const QString & svgData);
    void sigShowErrorText(const QString & txt, bool bShowOutputPage = true);

public slots:
    void sltFinishedGnuplot(int exitCode, QProcess::ExitStatus exitStatus);
    void sltErrorGnuplot(QProcess::ProcessError error);
    void sltErrorText(const QString & sTxt);
    void sltErrorTextWithoutPageActivation(const QString & sTxt);

private:
    void handleGnuplotError(int exitCode);
    void runGnuplot(const QString & sScript);

    QString   m_aLastGnuplotResult;
    QString   m_aLastGnuplotError;
    bool      m_bUseBeta;
    int       m_iResolution;
    int       m_iFontSize;
    int       m_iInvokeCount;
    QProcess  m_aGnuplotProcess;
};

#endif // GNUPLOTINVOKER_H
