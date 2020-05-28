/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#ifndef APPLICATIONDATA_H
#define APPLICATIONDATA_H

#include <QObject>

class ApplicationData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString homePath READ getHomePath)
    Q_PROPERTY(QString sdCardPath READ getSDCardPath)

public:
    explicit ApplicationData(QObject *parent = nullptr);

     Q_INVOKABLE QString normalizePath(const QString & path) const;
     Q_INVOKABLE QString readFileContent(const QString & fileName) const;
     Q_INVOKABLE bool writeFileContent(const QString & fileName, const QString & content);

     Q_INVOKABLE bool HasAccessToSDCardPath() const;
     Q_INVOKABLE bool GrantAccessToSDCardPath(QObject * parent);

     QString getHomePath() const;
     QString getSDCardPath() const;

     Q_INVOKABLE QString dumpDirectoryContent(const QString & path) const;

signals:

};

#endif // APPLICATIONDATA_H
