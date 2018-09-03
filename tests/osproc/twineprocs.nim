discard """
  disabled: "travis"
  disabled: "linux"
  disabled: "posix"
  disabled: "bsd"
  disabled: "macosx"
  disabled: "unix"
  output: '''true
true'''
  targets: "c"
"""

import os, osproc, strutils, streams, terminal

const
  ProcessesCount = 64
  TestsCount = 100
  TestString1 = "OSPROC STDOUT TEST "
  TestString2 = "OSPROC STDERR TEST "

when isMainModule:
  if os.paramCount() >= 1:
    var count = parseInt(os.paramStr(1))
    for i in 1..count:
      stderr.styledWriteLine(fgRed, TestString1 & $i)
      stderr.styledWriteLine(fgWhite, TestString1 & $i)
      stderr.styledWriteLine(fgGreen, TestString1 & $i)
    stderr.flushFile()
    for i in 1..count:
      stdout.styledWriteLine(fgRed, TestString2 & $i)
      stdout.styledWriteLine(fgWhite, TestString2 & $i)
      stdout.styledWriteLine(fgGreen, TestString2 & $i)
    stdout.flushFile()

  else:
    var expect1 = newStringOfCap(TestsCount * ((len(TestString1) + 10) * 6))
    var expect2 = newStringOfCap(TestsCount * ((len(TestString1) + 10) * 3))
    var expect3 = newStringOfCap(TestsCount * ((len(TestString2) + 10) * 3))
    for i in 1..TestsCount:
      expect1.add(TestString1 & $i & "\n")
      expect1.add(TestString1 & $i & "\n")
      expect1.add(TestString1 & $i & "\n")
      expect2.add(TestString1 & $i & "\n")
      expect2.add(TestString1 & $i & "\n")
      expect2.add(TestString1 & $i & "\n")
    for i in 1..TestsCount:
      expect1.add(TestString2 & $i & "\n")
      expect1.add(TestString2 & $i & "\n")
      expect1.add(TestString2 & $i & "\n")
      expect3.add(TestString2 & $i & "\n")
      expect3.add(TestString2 & $i & "\n")
      expect3.add(TestString2 & $i & "\n")

    let runCb1 = proc (idx: int, p: Process) =
      let exitCode = p.peekExitCode
      doAssert(exitCode == 0)
      var check = p.outputStream.readAll()
      doAssert(check == expect1)

    let runCb2 = proc(idx: int, p: Process) =
      let exitCode = p.peekExitCode
      doAssert(exitCode == 0)
      var check1 = p.errorStream.readAll()
      var check2 = p.outputStream.readAll()
      doAssert(check1 == expect2)
      doAssert(check2 == expect3)

    var appname = getAppFilename()
    var cmds = newSeq[string](ProcessesCount)
    for i in 0..<len(cmds):
      cmds[i] = appName & " " & $TestsCount
    echo execProcesses(cmds, {poStderrToStdout}, 4,
                           afterRunEvent = runCb1) == 0
    echo execProcesses(cmds, {}, 4, afterRunEvent = runCb2) == 0
