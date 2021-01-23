/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#ifndef ANDROIDTASKS_H
#define ANDROIDTASKS_H

#include <QObject>

#define CURRENT_FILE_NAME           "CURRENT_FILE_NAME"
#define CURRENT_SCRIPT              "CURRENT_SCRIPT"
#define CURRENT_HELP                "CURRENT_HELP"
#define CURRENT_FONT                "CURRENT_FONT"
#define LAST_DIRECTORY              "LAST_DIRECTORY"
#define LAST_FILENAME               "LAST_FILENAME"
#define LAST_HELP_INPUT             "LAST_HELP_INPUT"
#define LAST_RELEASE_DATE           "LAST_RELEASE_DATE"
#if defined(Q_OS_ANDROID)
#define DEFAULT_DIRECTORY           "/data/data/de.mneuroth.gnuplotviewerquick/files/scripts"
#define FILES_DIR                   "/data/data/de.mneuroth.gnuplotviewerquick/files/"
#define SCRIPTS_DIR                 "/data/data/de.mneuroth.gnuplotviewerquick/files/scripts/"
#define SDCARD_DIRECTORY            "/sdcard"
#elif defined(Q_OS_WASM)
#define DEFAULT_DIRECTORY           "/"
#define FILES_DIR                   "/"
#define SCRIPTS_DIR                 "/"
#define SDCARD_DIRECTORY            "/"
#elif defined(Q_OS_WIN)
#define DEFAULT_DIRECTORY           "C:\\usr\\neurothmi\\Android\\gnuplotviewerquick"
#define SDCARD_DIRECTORY            "c:\\tmp"
#define FILES_DIR                   "C:\\Users\\micha\\Documents\\git_projects\\GnuplotViewerQuick\\files\\"
#define SCRIPTS_DIR                 "C:\\usr\\neurothmi\\Android\\gnuplotviewerquick\\files\\scripts\\"
#elif defined(Q_OS_LINUX)
#define DEFAULT_DIRECTORY           "./scripts"
#define FILES_DIR                   "."
#define SCRIPTS_DIR                 "./scripts/"
#define SDCARD_DIRECTORY            "/sdcard"
#elif defined(Q_OS_WASM)
#define DEFAULT_DIRECTORY           "./scripts"
#define FILES_DIR                   "."
#define SCRIPTS_DIR                 "./scripts/"
#define SDCARD_DIRECTORY            "/sdcard"
#elif defined(Q_OS_IOS)
#define DEFAULT_DIRECTORY           "./scripts"
#define FILES_DIR                   "."
#define SCRIPTS_DIR                 "./scripts/"
#define SDCARD_DIRECTORY            "/sdcard"
#else
#define DEFAULT_DIRECTORY           "/Users/min/Documents/home"
#define SDCARD_DIRECTORY            "/Users/min"
#define FILES_DIR                   "/Users/min/Documents/home/Entwicklung/projects/gnuplotviewerquick/files/"
#define SCRIPTS_DIR                 "/Users/min/Documents/home/Entwicklung/projects/gnuplotviewerquick/files/scripts/"
#endif

#define DEFAULT_SCRIPT              QObject::tr("# This is a graphical frontend app for gnuplot.\n#\n# Enter gnuplot commands in this field and\n# execute script by activating the run button below.\n# Type help and hit run button for gnuplot help.\n#\n# See http://www.gnuplot.info/ for more information.\n#\n# example:\n\nplot sin(x), cos(x)\n")
#define DEFAULT_HELP                QObject::tr("# Enter commands to get help here\n# Example: help plot\n")

#define LICENSE                     QObject::tr("THIS SOFTWARE AND THE ACCOMPANYING FILES ARE SOLD \"AS IS\" AND WITHOUT\nWARRANTIES AS TO PERFORMANCE OR MERCHANTABILITY OR ANY OTHER WARRANTIES\nWHETHER EXPRESSED OR IMPLIED. Because of the various hardware and\nsoftware environments in which this software may be used,\nNO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS OFFERED.\n\nGood data processing procedure dictates that any program should\nbe thoroughly tested with non-critical data before relying on it.\nThe user must assume the entire risk of using the program.\nANY LIABILITY OF THE SELLER WILL BE LIMITED EXCLUSIVELY TO PRODUCT\nREPLACEMENT OR REFUND OF PURCHASE PRICE.")

#define ASSETS_DIR                  "assets:/files/"
#define ASSETS_SCRIPTS_DIR          "assets:/files/scripts/"
#define GNUPLOT_EXE                 "gnuplot_android"
#define GNUPLOT_BETA_EXE            "gnuplot_android_beta"
#define GNUPLOT_GIH                 "gnuplot.gih"
#define GNUPLOT_COPYRIGHT           "gnuplot_copyright"
#define GNUPLOTVIEWER_LICENSE       "gnuplotviewer_license.txt"
#define EMPTY_SVG                   "empty.svg"
#define FAQ_TXT                     "faq.txt"

#define SCRIPT1_GPT                 "simple.gpt"
#define SCRIPT2_GPT                 "fitdata.gpt"
#define SCRIPT3_GPT                 "splot.gpt"
#define SCRIPT4_GPT                 "multiplot.gpt"
#define SCRIPT5_GPT                 "butterfly.gpt"
#define SCRIPT6_GPT                 "default.gpt"
#define DATA2_DAT                   "data.dat"

// access to old versions of mobile gnuplot viewer
#define OLD_GNUPLOTVIEWER_SCRIPTS_DIR "/data/data/de.mneuroth.gnuplotviewer/files/scripts"
#define OLD_GNUPLOTVIEWERFREE_SCRIPTS_DIR "/data/data/de.mneuroth.gnuplotviewerfree/files/scripts"

class UnpackFilesThread;

bool HasAccessToSDCardPath();
bool GrantAccessToSDCardPath(QObject * parent);

class AndroidTasks : public QObject
{
    Q_OBJECT

public:
    AndroidTasks();
    ~AndroidTasks();

    void Init();

public slots:
    void sltUnpackFinished();

private:
    UnpackFilesThread * m_pUnpackThread;
};

#endif // ANDROIDTASKS_H
