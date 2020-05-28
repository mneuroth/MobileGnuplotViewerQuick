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
    app.setApplicationName("MobileGnuplotViewer");

    qmlRegisterType<GnuplotInvoker>("de.mneuroth.gnuplotinvoker", 1, 0, "GnuplotInvoker");

    AndroidTasks aAndroidTasks;
    aAndroidTasks.Init();

    // TODOs (QML):
    // - Hilfe Seite anlegen
    // - Ausgabe Seite anlegen
    // ok: - Gnuplot Syntax highlighter implementiern --> https://stackoverflow.com/questions/14791360/qt5-syntax-highlighting-in-qml
    // - Grafik Seite implementieren
    // - Gnuplot Invoker implementieren
    // - MobileFileDialog implementieren
    // - Android Share implementieren

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
/*
    QList<QObject*> rootObjects = engine.rootObjects();
    QObject * first = rootObjects.first();
    int count = rootObjects.count();
    QObject *rect = first->findChild<QObject*>("homePage");
    QObjectList childs = first->children();
    foreach (QObject* obj, childs)
    {
        qDebug() << obj->objectName() << endl;
    }
*/

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
