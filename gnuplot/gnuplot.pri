# Steps to use built in gnuplot:
# download current gnuplot sources and run:
#   >./configure --with-qt=no --without-x --without-cairo
# maybe changed some values in created config.h
#   set in config.h --> #undef HAVE_SIGSETJMP
#   set in config.h --> #undef HAVE_UNAME
#   set in config.h --> #undef HAVE_SYS_IOCTL_H
#   set in config.h --> #undef HAVE_LANGINFO_H
# copy from original gnuplot sources into MobileGnuplotViewerQuick/gnuplot:
#   src/*
#   term/*
# patch some sources:
#   add in strftime.c: for #ifdef TEST_STRFTIME
#     #else
#     #include "variable.h"
#   in plot.c
#     rename main( into gnu_main(

LIBS += -ldl

DEFINES += HAVE_CONFIG_H

INCLUDEPATH += gnuplot/term
INCLUDEPATH += gnuplot/src
INCLUDEPATH += gnuplot

SOURCES += \
        gnuplot/src/alloc.c \
        gnuplot/src/axis.c \
        gnuplot/src/bitmap.c \
        gnuplot/src/boundary.c \
        gnuplot/src/breaders.c \
        gnuplot/src/color.c \
        gnuplot/src/command.c \
        gnuplot/src/contour.c \
        gnuplot/src/datablock.c \
        gnuplot/src/datafile.c \
        gnuplot/src/dynarray.c \
        gnuplot/src/encoding.c \
        gnuplot/src/eval.c \
        gnuplot/src/external.c \
        gnuplot/src/fit.c \
        gnuplot/src/gadgets.c \
        gnuplot/src/getcolor.c \
        gnuplot/src/gpexecute.c \
        gnuplot/src/graph3d.c \
        gnuplot/src/graphics.c \
        gnuplot/src/help.c \
        gnuplot/src/hidden3d.c \
        gnuplot/src/history.c \
        gnuplot/src/internal.c \
        gnuplot/src/interpol.c \
        gnuplot/src/jitter.c \
        gnuplot/src/libcerf.c \
        gnuplot/src/matrix.c \
        gnuplot/src/misc.c \
        gnuplot/src/mouse.c \
        gnuplot/src/multiplot.c \
        gnuplot/src/parse.c \
        gnuplot/src/plot.c \
        gnuplot/src/plot2d.c \
        gnuplot/src/plot3d.c \
        gnuplot/src/pm3d.c \
        gnuplot/src/readline.c \
        gnuplot/src/save.c \
        gnuplot/src/scanner.c \
        gnuplot/src/set.c \
        gnuplot/src/show.c \
        gnuplot/src/specfun.c \
        gnuplot/src/standard.c \
        gnuplot/src/stats.c \
        gnuplot/src/stdfn.c \
        gnuplot/src/strftime.c \
        gnuplot/src/tables.c \
        gnuplot/src/tabulate.c \
        gnuplot/src/term.c \
        gnuplot/src/time.c \
        gnuplot/src/unset.c \
        gnuplot/src/util.c \
        gnuplot/src/util3d.c \
        gnuplot/src/variable.c \
        gnuplot/src/voxelgrid.c \
        gnuplot/src/vplot.c \
        gnuplot/src/version.c

HEADERS += \
    gnuplot/config.h \
    gnuplot/src/alloc.h \
    gnuplot/src/axis.h \
    gnuplot/src/bitmap.h \
    gnuplot/src/boundary.h \
    gnuplot/src/breaders.h \
    gnuplot/src/color.h \
    gnuplot/src/command.h \
    gnuplot/src/contour.h \
    gnuplot/src/datablock.h \
    gnuplot/src/datafile.h \
    gnuplot/src/dynarray.h \
    gnuplot/src/encoding.h \
    gnuplot/src/eval.h \
    gnuplot/src/external.h \
    gnuplot/src/fit.h \
    gnuplot/src/gadgets.h \
    gnuplot/src/getcolor.h \
    gnuplot/src/gp_hist.h \
    gnuplot/src/gp_time.h \
    gnuplot/src/gp_types.h \
    gnuplot/src/gpexecute.h \
    gnuplot/src/graph3d.h \
    gnuplot/src/graphics.h \
    gnuplot/src/hidden3d.h \
    gnuplot/src/internal.h \
    gnuplot/src/interpol.h \
    gnuplot/src/jitter.h \
    gnuplot/src/libcerf.h \
    gnuplot/src/matrix.h \
    gnuplot/src/misc.h \
    gnuplot/src/mouse.h \
    gnuplot/src/mousecmn.h \
    gnuplot/src/multiplot.h \
    gnuplot/src/national.h \
    gnuplot/src/parse.h \
    gnuplot/src/plot.h \
    gnuplot/src/plot2d.h \
    gnuplot/src/plot3d.h \
    gnuplot/src/pm3d.h \
    gnuplot/src/readline.h \
    gnuplot/src/save.h \
    gnuplot/src/scanner.h \
    gnuplot/src/setshow.h \
    gnuplot/src/specfun.h \
    gnuplot/src/standard.h \
    gnuplot/src/stats.h \
    gnuplot/src/stdfn.h \
    gnuplot/src/syscfg.h \
    gnuplot/src/tables.h \
    gnuplot/src/tabulate.h \
    gnuplot/src/template.h \
    gnuplot/src/term.h \
    gnuplot/src/term_api.h \
    gnuplot/src/util.h \
    gnuplot/src/util3d.h \
    gnuplot/src/variable.h \
    gnuplot/src/voxelgrid.h \
    gnuplot/src/vplot.h \
    gnuplot/src/version.h

