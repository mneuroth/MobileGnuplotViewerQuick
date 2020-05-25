#ifndef GNUPLOTINVOKER_H
#define GNUPLOTINVOKER_H

#include <QObject>
#include <QProcess>

class GnuplotInvoker : public QObject
{
    Q_OBJECT
public:
    GnuplotInvoker();

    Q_INVOKABLE QString run(const QString & sCmd);

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
    QProcess  m_aGnuplotProcess;
};

#endif // GNUPLOTINVOKER_H
