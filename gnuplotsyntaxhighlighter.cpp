/***************************************************************************
 *
 * MobileGnuplotViewer(Quick) - a simple frontend for gnuplot
 *
 * Copyright (C) 2020 by Michael Neuroth
 *
 * License: GPL
 *
 ***************************************************************************/

#include "gnuplotsyntaxhighlighter.h"

GnuplotSyntaxHighlighter::GnuplotSyntaxHighlighter(QTextDocument * parent)
    : QSyntaxHighlighter(parent)
{
    m_aKeywordFormat.setForeground(Qt::darkGreen);
    m_aKeywordFormat.setFontWeight(QFont::Bold);
    m_aFunctionsFormat.setForeground(Qt::blue);
    m_aFunctionsFormat.setFontWeight(QFont::Bold);
    m_aVariablesFormat.setForeground(Qt::darkMagenta);
    m_aVariablesFormat.setFontWeight(QFont::Bold);
    m_aConstantsFormat.setForeground(Qt::darkRed);
    m_aConstantsFormat.setFontWeight(QFont::Bold);
    m_aStringsFormat.setForeground(Qt::darkMagenta);
    m_aStringsFormat.setFontWeight(QFont::Bold);

    m_aCommentFormat.setForeground(Qt::gray);

    QStringList lstSymbolPatterns;

    lstSymbolPatterns
            << "\\bcd\\b" << "\\bcall\\b" << "\\bclear\\b"
            << "\\bexit\\b" << "\\bfit\\b" << "\\bhelp\\b"
            << "\\bhistory\\b" << "\\bif\\b" << "\\bload\\b"
            << "\\bpause\\b" << "\\bplot\\b" << "\\busing\\b"
            << "\\bu\\b" << "\\bwith\\b" << "\\bw\\b"
            << "\\bindex\\b" << "\\bevery\\b" << "\\bsmooth\\b"
            << "\\bthru\\b" << "\\bprint\\b" << "\\bpwd\\b"
            << "\\bquit\\b" << "\\breplot\\b" << "\\breread\\b"
            << "\\breset\\b" << "\\bsave\\b" << "\\bset\\b"
            << "\\bshow\\b" << "\\bshell\\b" << "\\bsplot\\b"
            << "\\bsystem\\b" << "\\btest\\b" << "\\bunset\\b"
            << "\\bupdate\\b" << "\\belse\\b" << "\\blower\\b"
            << "\\braise\\b" << "\\brefresh\\b" << "\\bscreendump\\b"
            << "\\bvia\\b";
    appendRules(lstSymbolPatterns,m_aKeywordFormat);

    lstSymbolPatterns.clear();
    lstSymbolPatterns
            << "\\babs\\b" << "\\bacos\\b" << "\\bacosh\\b"
            << "\\barg\\b" << "\\basin\\b" << "\\basinh\\b"
            << "\\batan\\b" << "\\batan2\\b" << "\\batanh\\b"
            << "\\bbesj0\\b" << "\\bbesj1\\b" << "\\bbesy0\\b"
            << "\\bbesy1\\b" << "\\bceil\\b" << "\\bcos\\b"
            << "\\bcosh\\b" << "\\berf\\b" << "\\berfc\\b"
            << "\\bexp\\b" << "\\bfloor\\b" << "\\bgamma\\b"
            << "\\bibeta\\b" << "\\binverf\\b" << "\\bigamma\\b"
            << "\\bimag\\b" << "\\binvnorm\\b" << "\\bint\\b"
            << "\\blambertw\\b" << "\\blgamma\\b" << "\\blog\\b"
            << "\\blog10\\b" << "\\bnorm\\b" << "\\brand\\b"
            << "\\breal\\b" << "\\bsgn\\b" << "\\bsin\\b"
            << "\\bsinh\\b" << "\\bsqrt\\b" << "\\btan\\b"
            << "\\btanh\\b" << "\\bcolumn\\b" << "\\bdefined\\b"
            << "\\btm_hour\\b" << "\\btm_mday\\b" << "\\btm_min\\b"
            << "\\btm_mon\\b" << "\\btm_sec\\b" << "\\btm_wday\\b"
            << "\\btm_yday\\b" << "\\btm_year\\b" << "\\bvalid\\b"
            << "\\bexistsgprintf\\b" << "\\bsprintf\\b" << "\\bstringcolumn\\b"
            << "\\bstrlen\\b" << "\\bstrstrt\\b" << "\\bsubstr\\b"
            << "\\bsystem\\b" << "\\bword\\b" << "\\bwords\\b"
            << "\\bpi\\b";
    appendRules(lstSymbolPatterns,m_aFunctionsFormat);

    lstSymbolPatterns.clear();
    lstSymbolPatterns
            << "\\bangles\\b" << "\\barrow\\b" << "\\bautoscale\\b"
            << "\\bbars\\b" << "\\bbmargin\\b" << "\\bborder\\b"
            << "\\bboxwidth\\b" << "\\bclabel\\b" << "\\bclip\\b"
            << "\\bcntrparam\\b" << "\\bcolorbox\\b" << "\\bcontour\\b"
            << "\\bdatafile\\b" << "\\bdecimalsign\\b" << "\\bdgrid3d\\b"
            << "\\bdummy\\b" << "\\bencoding\\b" << "\\bfontpath\\b"
            << "\\bformat\\b" << "\\bfunctions\\b" << "\\bfunction\\b"
            << "\\bgrid\\b" << "\\bhidden3d\\b" << "\\bhistorysize\\b"
            << "\\bisosamples\\b" << "\\bkey\\b" << "\\blabel\\b"
            << "\\blmargin\\b" << "\\bloadpath\\b" << "\\blocale\\b"
            << "\\blogscale\\b" << "\\bmapping\\b" << "\\bmargin\\b"
            << "\\bmouse\\b" << "\\bmultiplot\\b" << "\\bmx2tics\\b"
            << "\\bmxtics\\b" << "\\bmy2tics\\b" << "\\bmytics\\b"
            << "\\bmztics\\b" << "\\bnotitle\\b" << "\\boffsets\\b"
            << "\\borigin\\b" << "\\boutput\\b" << "\\bparametric\\b"
            << "\\bpm3d\\b" << "\\bpalette\\b" << "\\bpointsize\\b"
            << "\\bpolar\\b" << "\\bprint\\b" << "\\brmargin\\b"
            << "\\brrange\\b" << "\\bsamples\\b" << "\\bsize\\b"
            << "\\bstyle\\b" << "\\bsurface\\b" << "\\bterminal\\b"
            << "\\btics\\b" << "\\bticslevel\\b" << "\\bticscale\\b"
            << "\\btimestamp\\b" << "\\btimefmt\\b" << "\\btitle\\b"
            << "\\btmargin\\b" << "\\btrange\\b" << "\\burange\\b"
            << "\\bvariables\\b" << "\\bversion\\b" << "\\bview\\b"
            << "\\bvrange\\b" << "\\bx2data\\b" << "\\bx2dtics\\b"
            << "\\bx2label\\b" << "\\bx2mtics\\b" << "\\bx2range\\b"
            << "\\bx2tics\\b" << "\\bx2zeroaxis\\b" << "\\bxdata\\b"
            << "\\bxdtics\\b" << "\\bxlabel\\b" << "\\bxmtics\\b"
            << "\\bxrange\\b" << "\\bxtics\\b" << "\\bxzeroaxis\\b"
            << "\\by2data\\b" << "\\by2dtics\\b" << "\\by2label\\b"
            << "\\by2mtics\\b" << "\\by2range\\b" << "\\by2tics\\b"
            << "\\by2zeroaxis\\b" << "\\bydata\\b" << "\\bydtics\\b"
            << "\\bylabel\\b" << "\\bymtics\\b" << "\\byrange\\b"
            << "\\bytics\\b" << "\\byzeroaxis\\b" << "\\bzdata\\b"
            << "\\bzdtics\\b" << "\\bcbdata\\b" << "\\bcbdtics\\b"
            << "\\bzero\\b" << "\\bzeroaxis\\b" << "\\bzlabel\\b"
            << "\\bzmtics\\b" << "\\bzrange\\b" << "\\bztics\\b"
            << "\\bcblabel\\b" << "\\bcbmtics\\b" << "\\bcbrange\\b"
            << "\\bcbtics\\b" << "\\bbezier\\b" << "\\bbinary\\b"
            << "\\bcsplines\\b" << "\\bfrequency\\b" << "\\bmacros\\b"
            << "\\bmatrixobject\\b" << "\\bsbeszier\\b" << "\\btable\\b"
            << "\\btermoption\\b" << "\\bunique\\b" << "\\bxyplane\\b"
            << "\\bzzeroaxis\\b";
    appendRules(lstSymbolPatterns,m_aVariablesFormat);

    lstSymbolPatterns.clear();
    lstSymbolPatterns
            << "\\bFIT_CONVERGED\\b" << "\\bFIT_LAMBDA_FACTOR\\b"
            << "\\bFIT_LIMIT\\b" << "\\bFIT_LOG\\b" << "\\bFIT_MAXITER\\b"
            << "\\bFIT_NDF\\b" << "\\bFIT_SCRIPT\\b" << "\\bFIT_START_LAMBDA\\b"
            << "\\bFIT_STDFIT\\b" << "\\bFIT_WSSR\\b" << "\\bGNUTERM\\b"
            << "\\bMOUSE_ALT\\b" << "\\bMOUSE_BUTTON\\b" << "\\bMOUSE_CHAR\\b"
            << "\\bMOUSE_CTRL\\b" << "\\bMOUSE_KEY\\b" << "\\bMOUSE_SHIFT\\b"
            << "\\bMOUSE_X\\b" << "\\bMOUSE_X2\\b" << "\\bMOUSE_Y\\b"
            << "\\bMOUSE_Y2\\b" << "\\bGPVAL_CB_LOG\\b" << "\\bGPVAL_CB_MAX\\b"
            << "\\bGPVAL_CB_MIN\\b" << "\\bGPVAL_CB_REVERSE\\b" << "\\bGPVAL_COMPILE_OPTIONS\\b"
            << "\\bGPVAL_LAST_PLOT\\b" << "\\bGPVAL_MULTIPLOT\\b" << "\\bGPVAL_OUTPUT\\b"
            << "\\bGPVAL_PATCHLEVEL\\b" << "\\bGPVAL_PLOT\\b" << "\\bGPVAL_SPLOT\\b"
            << "\\bGPVAL_TERM\\b" << "\\bGPVAL_TERMOPTIONS\\b" << "\\bGPVAL_T_LOG\\b"
            << "\\bGPVAL_T_MAX\\b" << "\\bGPVAL_T_MIN\\b" << "\\bGPVAL_T_REVERSE\\b"
            << "\\bGPVAL_U_LOG\\b" << "\\bGPVAL_U_MAX\\b" << "\\bGPVAL_U_MIN\\b"
            << "\\bGPVAL_U_REVERSE\\b" << "\\bGPVAL_VERSION\\b" << "\\bGPVAL_VIEW_MAP\\b"
            << "\\bGPVAL_VIEW_ROT_X\\b" << "\\bGPVAL_VIEW_ROT_Z\\b" << "\\bGPVAL_VIEW_SCALE\\b"
            << "\\bGPVAL_VIEW_ZSCALE\\b" << "\\bGPVAL_V_LOG\\b" << "\\bGPVAL_V_MAX\\b"
            << "\\bGPVAL_V_MIN\\b" << "\\bGPVAL_V_REVERSE\\b" << "\\bGPVAL_X2_LOG\\b"
            << "\\bGPVAL_X2_MAX\\b" << "\\bGPVAL_X2_MIN\\b" << "\\bGPVAL_X2_REVERSE\\b"
            << "\\bGPVAL_X_LOG\\b" << "\\bGPVAL_X_MAX\\b" << "\\bGPVAL_X_MIN\\b"
            << "\\bGPVAL_X_REVERSE\\b" << "\\bGPVAL_Y2_LOG\\b" << "\\bGPVAL_Y2_MAX\\b"
            << "\\bGPVAL_Y2_MIN\\b" << "\\bGPVAL_Y2_REVERSE\\b" << "\\bGPVAL_Y_LOG\\b"
            << "\\bGPVAL_Y_MAX\\b" << "\\bGPVAL_Y_MIN\\b" << "\\bGPVAL_Y_REVERSE\\b"
            << "\\bGPVAL_Z_LOG\\b" << "\\bGPVAL_Z_MAX\\b" << "\\bGPVAL_Z_MIN\\b"
            << "\\bGPVAL_Z_REVERSE\\b" << "\\bGPVAL_TERMINALS\\b";
    appendRules(lstSymbolPatterns,m_aConstantsFormat);

    lstSymbolPatterns.clear();
    lstSymbolPatterns
            << "\"([^\\\"]|\\.)*\""
            << "\\("
            << "\\)";
    appendRules(lstSymbolPatterns,m_aStringsFormat);
}

void GnuplotSyntaxHighlighter::appendRules(const QStringList & lstSymbolPatterns, const QTextCharFormat & aFormat)
{
    HighlightingRule aRule;
    foreach (const QString &sPattern, lstSymbolPatterns)
    {
        aRule.pattern = QRegExp(sPattern);
        aRule.format = aFormat;
        m_aHighlightingRules.append(aRule);
    }
}

void GnuplotSyntaxHighlighter::highlightBlock(const QString &sText)
{
    // remove comments... (all chars after a # is a comment)
    QString text = sText;
    int iFound = text.indexOf('#');
    if( iFound>=0 )
    {
        // update color for comment...
        text = text.mid(0,iFound);
        setFormat(iFound, sText.length()-iFound, m_aCommentFormat);
    }

    foreach (const HighlightingRule &rule, m_aHighlightingRules) {
        QRegExp expression(rule.pattern);
        int index = expression.indexIn(text);
        while (index >= 0) {
            int length = expression.matchedLength();
            setFormat(index, length, rule.format);
            index = expression.indexIn(text, index + length);
        }
    }

    QTextCharFormat myClassFormat;
    myClassFormat.setFontWeight(QFont::Bold);
    myClassFormat.setForeground(Qt::darkMagenta);


// http://astro.berkeley.edu/~mkmcc/software/src/gnuplot.html
// https://groups.google.com/forum/?fromgroups#!topic/comp.graphics.apps.gnuplot/UufLJwOntCE
// http://www.vim.org/scripts/script.php?script_id=1737
// http://lists.kde.org/?l=kwrite-devel&m=108299163904146

// numbers, strings, operators, klammern, constants, variables, functions, commands
/*
    QString pattern = "\\bMy[A-Za-z]+\\b";
    //QString pattern = "\\b[0-9\.,eE+-]+\\b";
    //QString pattern = "\\b[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)\\b";
    QRegExp expression(pattern);
    int index = text.indexOf(expression);
    while (index >= 0) {
        int length = expression.matchedLength();
        setFormat(index, length, myClassFormat);
        index = text.indexOf(expression, index + length);
    }
*/
}
