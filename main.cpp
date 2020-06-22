/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQuickTextDocument>
#include <QQmlContext>

#include <QDateTime>

#include "gnuplotinvoker.h"
#include "gnuplotsyntaxhighlighter.h"
#include "applicationdata.h"
#include "storageaccess.h"
#include "androidtasks.h"
#include "applicationui.hpp"

#include <QtGlobal>
#include <QDir>
#include <QFile>

#include <QTranslator>
//#include <QQuickStyle>

#undef _WITH_QDEBUG_REDIRECT
#undef _WITH_ADD_TO_LOG

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
#ifdef _WITH_ADD_TO_LOG
    QString sFileName("/sdcard/Texte/mgv_qdebug.log");
    if( !QDir("/sdcard/Texte").exists() )
    {
        sFileName = "mgv_qdebug.log";
    }
    QFile outFile(sFileName);
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    qint64 delta = now - g_iLastTimeStamp;
    g_iLastTimeStamp = now;
    ts << delta << " ";
    ts << msg << endl;
    qDebug() << delta << " " << msg << endl;
#else
    Q_UNUSED(msg)
#endif
}

#ifdef _WITH_QDEBUG_REDIRECT
#include <QDebug>
void PrivateMessageHandler(QtMsgType type, const QMessageLogContext & context, const QString & msg)
{
    QString txt;
    switch (type) {
    case QtDebugMsg:
        txt = QString("Debug: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtInfoMsg:
        txt = QString("Info: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    }
    AddToLog(txt);
}
#endif

int main(int argc, char *argv[])
{
// TODO DEBUGGING: AddToLog(QString("###> RESTART main()"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    //QQuickStyle::setStyle("Default");  // Material Universal Fusion Imagine /Light Dark System --> C:\Qt\5.14.2\msvc2017_64\qml\QtQuick\Controls.2

    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("MobileGnuplotViewerQuick");

// TODO DEBUGGING: AddToLog("Starting APP");

#ifdef _WITH_QDEBUG_REDIRECT
    qInstallMessageHandler(PrivateMessageHandler);
#endif

#if defined(Q_OS_ANDROID)
    AddToLog("Starting ApplicationUI");

    ApplicationUI appui;
#endif

    qmlRegisterType<GnuplotInvoker>("de.mneuroth.gnuplotinvoker", 1, 0, "GnuplotInvoker");
    //qmlRegisterType<StorageAccess>("de.mneuroth.storageaccess", 1, 0, "StorageAccess");

    AndroidTasks aAndroidTasks;
    aAndroidTasks.Init();

    StorageAccess aStorageAccess;

    QTranslator qtTranslator;
    QString sLanguage = QLocale::system().name().mid(0,2).toLower();
    // for testing languages:
    //sLanguage = "nl";
    QString sResource = ":/translations/GnuplotViewerQuick_" + sLanguage + "_" + sLanguage.toUpper() + ".qm";
    /*bool ok =*/ qtTranslator.load(sResource);
    app.installTranslator(&qtTranslator);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
#if defined(Q_OS_ANDROID)
    QObject::connect(&app, SIGNAL(applicationStateChanged(Qt::ApplicationState)), &appui, SLOT(onApplicationStateChanged(Qt::ApplicationState)));
    QObject::connect(&app, SIGNAL(saveStateRequest(QSessionManager &)), &appui, SLOT(onSaveStateRequest(QSessionManager &)), Qt::DirectConnection);
    QObject::connect(&appui, SIGNAL(requestApplicationQuit()), &app, SLOT(quit())/* , Qt::QueuedConnection*/);
#endif

#if defined(Q_OS_ANDROID)
    ApplicationData data(0, appui.GetShareUtils(), aStorageAccess, engine);
    QObject::connect(&app, SIGNAL(applicationStateChanged(Qt::ApplicationState)), &data, SLOT(sltApplicationStateChanged(Qt::ApplicationState)));
#else
    ApplicationData data(0, new ShareUtils(), aStorageAccess, engine);
#endif
    engine.rootContext()->setContextProperty("applicationData", &data);
    engine.rootContext()->setContextProperty("storageAccess", &aStorageAccess);

    engine.load(url);

    GnuplotSyntaxHighlighter * pHighlighter = 0;
    QQuickTextDocument* doc = childObject<QQuickTextDocument*>(engine, "textArea", "textDocument");
    if( doc!=0 )
    {
        // this call invokes a onTextChanged for the textArea !
        pHighlighter = new GnuplotSyntaxHighlighter(doc->textDocument());
        pHighlighter->rehighlight();
    }

    data.initDone();

    int result = app.exec();

    if( pHighlighter )
    {
        delete pHighlighter;
    }

// TODO DEBUGGING: AddToLog(QString("###> SHUTDOWN result=%1").arg(result));

    return result;
}
