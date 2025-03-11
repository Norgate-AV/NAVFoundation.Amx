#DEFINE TESTING_NAVPATHBASENAME
#DEFINE TESTING_NAVPATHEXTNAME
#DEFINE TESTING_NAVPATHDIRNAME
#DEFINE TESTING_NAVPATHNORMALIZE
#DEFINE TESTING_NAVPATHRESOLVE
#DEFINE TESTING_NAVPATHJOINPATH
#DEFINE TESTING_NAVPATHRELATIVE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVPATHBASENAME
#include 'NAVPathBaseName.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHEXTNAME
#include 'NAVPathExtName.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHDIRNAME
#include 'NAVPathDirName.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHNORMALIZE
#include 'NAVPathNormalize.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHRESOLVE
#include 'NAVPathResolve.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHJOINPATH
#include 'NAVPathJoinPath.axi'
#END_IF

#IF_DEFINED TESTING_NAVPATHRELATIVE
#include 'NAVPathRelative.axi'
#END_IF

DEFINE_CONSTANT

constant char PATH_UTILS_PATHS[][255] = {
    '/home/user/file.txt',
    'home/user/docs/file.txt',
    '\\home\\user\\docs\\file.txt',
    '\home\user\docs\projects\file.txt',
    '/lost+found/fortunate_yuck.xht',
    '/usr/ports/joyfully.ico',
    '/lib/now_goodwill_yearningly.gif',
    '/net/duh_bandana_after.so',
    '/Users/manicure_instead.lrf',
    '/var/yp/barring_unfortunately.bin',
    '',
    '/',
    'home',
    'home/',
    './home',
    '../home',
    'home/user',
    'home/user/',
    '.',
    '..',
    '/',
    '/var/yp/barring_unfortunately.bin.bak'
}


define_function RunPathUtilsTests() {
    #IF_DEFINED TESTING_NAVPATHBASENAME
    TestNAVPathBaseName(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHEXTNAME
    TestNAVPathExtName(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHDIRNAME
    TestNAVPathDirName(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHNORMALIZE
    TestNAVPathNormalize(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHRESOLVE
    TestNAVPathResolve(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHJOINPATH
    TestNAVPathJoinPath(PATH_UTILS_PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHRELATIVE
    TestNAVPathRelative(PATH_UTILS_PATHS)
    #END_IF
}
