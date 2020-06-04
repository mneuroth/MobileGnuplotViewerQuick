/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

// TODOs (QML):
// ok: - Gnuplot Syntax highlighter implementiern --> https://stackoverflow.com/questions/14791360/qt5-syntax-highlighting-in-qml
// ok: - Gnuplot Invoker implementieren
//
// Implement
// ok: - Zoom/Pitch für Grafik Seite implementieren
// ok: Storage funktioniert nicht mehr --> Java Klasse schuld? --> ja
// Teilen Empfangen funktioniert nicht mehr --> ok, aber Probleme, siehe unten
// Teilen arbeitet nicht gut zusammen mit eingebautem Storage Framework Support bei QFileDialog
// Teilen Problem: App offen, Umschalten mit O Button und Aufruf von eier anderen App --> App wird nicht korrekt angezeigt und blockiert
//   --> ok, wenn App vorher geschlossen wird (mit Back-Button)
// Bei SD Karten sowohl intern als auch extern anzeigen
// - MobileFileDialog verbessern (Label Beschriftungen, Buttons ausblenden)
// - Save auf Android Storage Framework --> wie geht das mit eingebautem Support QFileDialog ?
// - Save auf Android Storage Framework funktioniert auch nicht bei alten Apps --> visiscript ok, mobilegnuplotviewer ERROR
// ok: - reload der zuletzt geöffneten Datei implementieren
// ok: - demo Skripte werden bei jedem Neustart der App überschrieben (da wieder ausgepackt)
// - Einstellungen erlauben: Groesse fuer SVG plot und Font Name und Groesse einstellbar machen
// ok: - Save As
// - Back Button soll nicht direkt Anwendung schliessen
// - Drucken ?
// - About Dialog
// ok: - Hilfe Seite anlegen
// ok: - Ausgabe Seite anlegen
// ok: - Android Share/Teilen
// - Google Play Spenden/Bezahloptionen einbauen
// - Zugriff auf alte MobileGnuplotViewer Files Verzeichnisse gewähren,
// - Pay Features ok, falls alter kommerzieller MobileGnuplotViewer vorhanden
// - ggf. Zeichensatz aenderbar
// - ggf. Einstellungen Aussehen aenderbar
// - ggf. Dateien loeschen
// ok: - ggf. FAQs, Lizenz, gnuplot version, gnuplot hilfe, gnuplot copyright
// - ggf. Bearbeiten Menu (copy/paste) --> nicht notwendig, da via context moeglich
// ok: - ggf. Senden
// ok: - ggf. verwende gnuplot beta
//
// - MobileGnuplotViewerFree/Com neu bauen mit Referenz auf neue Quick Implementierung

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

#define _WITH_QDEBUG_REDIRECT

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
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
AddToLog(QString("###> RESTART main()"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("MobileGnuplotViewerQuick");

    AddToLog("Starting APP");

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
        pHighlighter = new GnuplotSyntaxHighlighter(doc->textDocument());
    }

    int result = app.exec();

    if( pHighlighter )
    {
        delete pHighlighter;
    }

AddToLog(QString("###> SHUTDOWN result=%1").arg(result));
    return result;
}
