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
#include <QProcess>

class GnuplotInvoker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ getLastError)
    Q_PROPERTY(bool useBeta READ getUseBeta WRITE setUseBeta)

public:
    GnuplotInvoker();

    Q_INVOKABLE QString run(const QString & sCmd);

    QString getLastError() const;
    bool getUseBeta() const;
    void setUseBeta(bool value);

signals:
    void sigResultReady(const QString & svgData);

public slots:
    void sltRunGnuplot();

    void sltFinishedGnuplot(int exitCode, QProcess::ExitStatus exitStatus);
    void sltErrorGnuplot(QProcess::ProcessError error);
    void sltErrorText(const QString & sTxt);

private:
    void handleGnuplotError(int exitCode);
    void runGnuplot(const QString & sScript);

    QString   m_aLastGnuplotResult;
    QString   m_aLastGnuplotError;
    bool      m_bUseBeta;
    QProcess  m_aGnuplotProcess;
};

#endif // GNUPLOTINVOKER_H
