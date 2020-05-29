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
// - Zoom/Pitch für Grafik Seite implementieren
// - MobileFileDialog verbessern (Label Beschriftungen, Buttons ausblenden)
// - reload der zuletzt geöffneten Datei implementieren
// - demo Skripte werden bei jedem Neustart der App überschrieben (da wieder ausgepackt)
// - Save As
// - About Dialog
// - Hilfe Seite anlegen
// - Ausgabe Seite anlegen
// - Android Share/Teilen
// - Google Play Spenden/Bezahloptionen einbauen
// - Zugriff auf alte MobileGnuplotViewer Files Verzeichnisse gewähren,
// - Pay Features ok, falls alter kommerzieller MobileGnuplotViewer vorhanden
// - ggf. Zeichensatz aenderbar
// - ggf. Einstellungen Aussehen aenderbar
// - ggf. Dateien loeschen
// - ggf. FAQs, Lizenz, gnuplot version, gnuplot hilfe, gnuplot copyright
// - ggf. Bearbeiten Menu (copy/paste) --> nicht notwendig, da via context moeglich
// - ggf. Senden
// - ggf. verwende gnuplot beta
//
// - MobileGnuplotViewerFree/Com neu bauen mit Referenz auf neue Quick Implementierung

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQuickTextDocument>
#include <QQmlContext>

#include "gnuplotinvoker.h"
#include "gnuplotsyntaxhighlighter.h"
#include "applicationdata.h"
#include "androidtasks.h"

#include <QDebug>
#include <QtGlobal>

// see: https://stackoverflow.com/questions/14791360/qt5-syntax-highlighting-in-qml
template <class T> T childObject(QQmlApplicationEngine& engine,
                                 const QString& objectName,
                                 const QString& propertyName)
{
    QList<QObject*> rootObjects = engine.rootObjects();
    foreach (QObject* object, rootObjects)
    {
        QObject* child = object->findChild<QObject*>(objectName);
        if (child != 0)
        {
            std::string s = propertyName.toStdString();
            QObject* object = child->property(s.c_str()).value<QObject*>();
            Q_ASSERT(object != 0);
            T prop = dynamic_cast<T>(object);
            Q_ASSERT(prop != 0);
            return prop;
        }
    }
    return (T) 0;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("MobileGnuplotViewerQuick");

    qmlRegisterType<GnuplotInvoker>("de.mneuroth.gnuplotinvoker", 1, 0, "GnuplotInvoker");

    AndroidTasks aAndroidTasks;
    aAndroidTasks.Init();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);


    ApplicationData data;
    engine.rootContext()->setContextProperty("applicationData", &data);

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

    return result;
}
