import posix, logging

# thank you status-im :)
{.pragma: syslog_h, importc, header: "<syslog.h>"}

# proc openlog(ident: cstring, option, facility: int) {.syslog_h.}
proc syslog(priority: int, format: cstring, msg: cstring) {.syslog_h.}
# proc closelog() {.syslog_h.}

var LOG_EMERG {.syslog_h.}: int
var LOG_ALERT {.syslog_h.}: int
var LOG_CRIT {.syslog_h.}: int
var LOG_ERR {.syslog_h.}: int
var LOG_WARNING {.syslog_h.}: int
var LOG_NOTICE {.syslog_h.}: int
var LOG_INFO {.syslog_h.}: int
var LOG_DEBUG {.syslog_h.}: int

var LOG_PID {.syslog_h.}: int

type SyslogLogger* = ref object of Logger

proc lvlToSyslogLevel(lvl: Level): int =
  ## converts the nim log `Level` to the syslog level.
  ## Invalid levels are mapped to `-1` and should be ignored later
  case lvl
  of lvlAll: -1                 ## All levels active
  of lvlDebug: LOG_DEBUG                ## Debug level and above are active
  of lvlInfo: LOG_INFO                 ## Info level and above are active
  of lvlNotice: LOG_NOTICE               ## Notice level and above are active
  of lvlWarn: LOG_WARNING                 ## Warn level and above are active
  of lvlError: LOG_ERR                ## Error level and above are active
  of lvlFatal: LOG_CRIT                ## Fatal level and above are active
  of lvlNone: -1                    ## No levels active; nothing is logged
  else: -1

proc newSyslogLogger*(levelThreshold = lvlAll, fmtStr = defaultFmtStr): SyslogLogger =
  ## A new syslog logger
  ## 
  ## .. code-block::
  ##   var syslogLog = newSyslogLogger()
  ##   addHandler(syslogLog)
  ##   info("INFO")
  ##   warn("WARN")
  ##   error("ERR")

  result = SyslogLogger()
  result.levelThreshold = levelThreshold
  result.fmtStr = fmtStr

method log*(logger: SyslogLogger, level: Level, args: varargs[string, `$`]) =
  # if level >= logging.level and level >= logger.levelThreshold:
  if level >= logger.levelThreshold:
    let syslogLevel = lvlToSyslogLevel(level)
    let ln = substituteLog(logger.fmtStr, level, args)
    syslog(syslogLevel, "%s", ln)

when isMainModule:
  syslog(LOG_WARNING, "%s", "TEST 123")
  var syslogLog = newSyslogLogger()
  addHandler(syslogLog)
  info("INFO")
  warn("WARN")
  error("ERR")

