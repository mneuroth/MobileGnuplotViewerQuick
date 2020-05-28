/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#ifndef GNUPLOTSYNTAXHIGHLIGHTER_H
#define GNUPLOTSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegExp>
#include <QVector>

class QTextDocument;

class GnuplotSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    GnuplotSyntaxHighlighter(QTextDocument * parent);

protected:
    virtual void highlightBlock(const QString &text);

private:
    void appendRules(const QStringList & lstSymbolPatterns, const QTextCharFormat & aFormat);

    struct HighlightingRule
    {
        QRegExp                 pattern;
        QTextCharFormat         format;
    };
    QVector<HighlightingRule>   m_aHighlightingRules;

// numbers, strings, operators, klammern, constants, variables, functions, commands

    QTextCharFormat             m_aKeywordFormat;
    QTextCharFormat             m_aCommentFormat;
    QTextCharFormat             m_aNumbersFormat;
    QTextCharFormat             m_aStringsFormat;
    QTextCharFormat             m_aConstantsFormat;
    QTextCharFormat             m_aVariablesFormat;
    //QTextCharFormat             m_aCommandsFormat;
    QTextCharFormat             m_aFunctionsFormat;
};

#endif // GNUPLOTSYNTAXHIGHLIGHTER_H
