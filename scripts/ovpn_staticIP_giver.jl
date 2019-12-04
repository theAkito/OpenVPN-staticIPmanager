#!/usr/bin/env julia
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>

using Dates

if length(ARGS) >= 1 && ARGS[1] == "init"
  println("Create new configuration file?")
  println("If an old configuration file exists it will be backed up.")
  print("Enter YES if you agree: ")
  agreement = readline(stdin)
  if agreement == "YES"
    cT = Dates.format(now(), "yyyymmddHHMMSS")
    filename = "static_IPs.cfg"
    bkfilename = "static_IPs.cfg.$cT"
    try
      oldfile = open(filename, "r")
      newfile = open(bkfilename, "w")
      write(newfile, oldfile)
      close(newfile)
    catch
      file = open(filename, "w")
      write(file, "")
      close(file)
    end
  else
    println("Request denied. Exiting.")
  end
elseif length(ARGS) == 0
  println("placeholder")
end
