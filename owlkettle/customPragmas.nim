## Definess a custom pragma called "locker".
## This does nothing when compiled with a nim version 2.0 or higher,
## but applies the "locks: 0" pragma if compiled for e.g. 1.6.X.
## "locks: 0" is applied to ensure that this code never accesses locked data in user-defined procs.
when NimMajor >= 2:
  {.pragma: locker.}
else:
  {.pragma: locker, locks: 0.}