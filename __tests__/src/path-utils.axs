PROGRAM_NAME='path-utils'

#DEFINE __MAIN__
#DEFINE TESTING_NAVPATHBASENAME
#DEFINE TESTING_NAVPATHEXTNAME
#DEFINE TESTING_NAVPATHDIRNAME
#DEFINE TESTING_NAVPATHNORMALIZE
#DEFINE TESTING_NAVPATHJOINPATH
#include 'NAVFoundation.Core.axi'
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
#IF_DEFINED TESTING_NAVPATHJOINPATH
#include 'NAVPathJoinPath.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char PATHS[][255] = {
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


define_function RunTests() {
    #IF_DEFINED TESTING_NAVPATHBASENAME
    TestNAVPathBaseName(PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHEXTNAME
    TestNAVPathExtName(PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHDIRNAME
    TestNAVPathDirName(PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHNORMALIZE
    TestNAVPathNormalize(PATHS)
    #END_IF

    #IF_DEFINED TESTING_NAVPATHJOINPATH
    TestNAVPathJoinPath(PATHS)
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
