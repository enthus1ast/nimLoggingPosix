An extention for nim's `std/logging` to also log on posix syslog.

usage:

```nim
import loggingPosix

var syslogLog = newSyslogLogger()
addHandler(syslogLog)
info("INFO")
warn("WARN")
error("ERR")
```