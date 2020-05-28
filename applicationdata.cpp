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

#include <QDir>
#include <QUrl>
#include <QFile>
#include <QTextStream>

ApplicationData::ApplicationData(QObject *parent) : QObject(parent)
{
}

QString ApplicationData::normalizePath(const QString & path) const
{
    QDir aInfo(path);
    return aInfo.canonicalPath();
}

QString ApplicationData::readFileContent(const QString & fileName) const
{
    QUrl url(fileName);
    QFile file(url.toLocalFile());

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QTextStream stream(&file);
    auto text = stream.readAll();

    file.close();

    return text;
}

QString ApplicationData::getHomePath() const
{
#if defined(Q_OS_ANDROID)
    return SCRIPTS_DIR;
#elif defined(Q_OS_WINDOWS)
    return "c:\\tmp";
#else
    return ".";
#endif
}

QString ApplicationData::getSDCardPath() const
{
#if defined(Q_OS_ANDROID)
    return "/sdcard"; // FILES_DIR;
#elif defined(Q_OS_WIN)
    return "g:\\";
#else
    return "/sdcard";
#endif
}
