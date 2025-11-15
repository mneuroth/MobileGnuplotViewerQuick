#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>
#include <QIcon>
#include <QtGlobal>
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QQuickStyle>
#include <QQuickTextDocument>
#include <QSettings>

#include "applicationdata.h"
#include "gnuplotinvoker.h"

#ifdef _WITH_STORAGE_ACCESS
#include "storageaccess.h"
#endif
#ifdef _WITH_SHARING
#include "shareutils.hpp"
#endif
#if defined(Q_OS_ANDROID)
#include "applicationui.hpp"
#endif

#define _WITH_QDEBUG_REDIRECT
#define _WITH_ADD_TO_LOG

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
#ifdef _WITH_ADD_TO_LOG
    QString sFileName("/sdcard/Texte/picoapptpl_qdebug.log");
    if( !QDir("/sdcard/Texte").exists() )
    {
        sFileName = "D:\\Users\\micha\\Documents\\git_projects\\build-pico-Desktop_Qt_6_2_2_MinGW_64_bit-Debug\\picoapp_qdebug.log";
        sFileName = "picoapptpl_qdebug.log";
    }
    QFile outFile(sFileName);
    bool ok = outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Unbuffered);
    QTextStream ts(&outFile);
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    qint64 delta = now - g_iLastTimeStamp;
    g_iLastTimeStamp = now;
    ts << delta << " ";
    ts << msg << Qt::endl;
    //qDebug() << delta << " " << msg << Qt::endl;
    outFile.close();
#else
    Q_UNUSED(msg)
#endif
}

#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

void copyResourceToFileSystem(const QString &resourcePath, const QString &targetFileName) {
    QFile resourceFile(resourcePath); // z. B. ":/data/template.txt"
    if (!resourceFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Konnte Resource nicht öffnen:" << resourcePath;
        return;
    }

    QString targetDir = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QDir().mkpath(targetDir); // Verzeichnis erstellen, falls nicht vorhanden

    QString targetPath = targetDir + QDir::separator() + targetFileName;
    QFile targetFile(targetPath);
    if (!targetFile.exists())
    {
        if (!targetFile.open(QIODevice::WriteOnly))
        {
            qWarning() << "Konnte Zieldatei nicht schreiben:" << targetPath;
            return;
        }
        targetFile.write(resourceFile.readAll());
        targetFile.close();
    }
    resourceFile.close();

    qDebug() << "Datei erfolgreich kopiert nach:" << targetPath;
}

void ensureDirectoryExists(const QString &path)
{
    QDir dir(path);
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning("Verzeichnis konnte nicht erstellt werden: %s", qUtf8Printable(path));
        }
    }
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("MobileGnuplotViewerQuick");
    app.setWindowIcon(QIcon(":/qt/qml/GnuplotViewerQuick/images/gnuplotviewer_flat_512x512.png"));

    QSettings aSettings;
    QString sStyle = aSettings.value("appStyle", "Basic").toString();
    sStyle = "Default";
#if defined(Q_OS_ANDROID)
    sStyle = "Basic";
#endif
    qDebug() << "STYLE: " << sStyle << Qt::endl;
    QQuickStyle::setStyle(sStyle); // Basic, Fusion, Imagine, macOS, Material, Universal, Windows
    //QStringList allStyles = QQuickStyle::availableStyles();
    //qDebug() << allStyles << Qt::endl;

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "GnuplotViewerQuick_" + QLocale(locale).name();
        if (translator.load(":/" + baseName)) {     // translations/
            app.installTranslator(&translator);
            break;
        }
    }

#if defined(Q_OS_ANDROID)
    QString targetDir = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QDir().mkpath(targetDir); // Verzeichnis erstellen, falls nicht vorhanden
    QString targetPath = targetDir + "/scripts";
    ensureDirectoryExists(targetPath);
    copyResourceToFileSystem(":files/scripts/default.gpt", "scripts/default.gpt");
    copyResourceToFileSystem(":files/scripts/simple.gpt", "scripts/simple.gpt");
    copyResourceToFileSystem(":files/scripts/splot.gpt", "scripts/splot.gpt");
    copyResourceToFileSystem(":files/scripts/fitdata.gpt", "scripts/fitdata.gpt");
    copyResourceToFileSystem(":files/scripts/multiplot.gpt", "scripts/multiplot.gpt");
    copyResourceToFileSystem(":files/scripts/butterfly.gpt", "scripts/butterfly.gpt");
    copyResourceToFileSystem(":files/scripts/data.dat", "scripts/data.dat");
    copyResourceToFileSystem(":files/faq.txt", "faq.txt");
    copyResourceToFileSystem(":files/gnuplotviewer_license.txt", "gnuplotviewer_license.txt");
    copyResourceToFileSystem(":files/gnuplot_copyright", "gnuplot_copyright");
#endif

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt/qml/GnuplotViewerQuick/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

#if defined(Q_OS_ANDROID)
    ApplicationUI appui;
#endif
    StorageAccess aStorageAccess;
    qmlRegisterType<GnuplotInvoker>("de.mneuroth.gnuplotinvoker", 1, 0, "GnuplotInvoker");

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
#ifdef _WITH_STORAGE_ACCESS
    engine.rootContext()->setContextProperty("storageAccess", &aStorageAccess);
#endif

    engine.load(url);

    QQuickTextDocument* pDoc = childObject<QQuickTextDocument*>(engine, "textArea", "textDocument");
    data.setTextDocument(pDoc);

    data.initDone();

    return app.exec();
}
