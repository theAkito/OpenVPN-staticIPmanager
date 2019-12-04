#!/usr/bin/env julia
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>

using Dates

if length(ARGS) >= 1 && ARGS[1] == "init"
  ## Creates configuration file.
  ## Backs up old cfg and/or creates new and empty one.
  ##
  ###  Usage
  ## ./ovpn_staticIP_giver.jl init
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
elseif length(ARGS) >= 1 && ARGS[1] == "emergency"
  ## Pray to Satan for this to never be necessary.
  ##
  ## Creates static IPs for each client manually.
  ## Needed if the config folder is lost and
  ## every config needs to be redone for
  ## assuring the clients their respective IP.
  ##
  ###  Usage
  ## First, create file "clients.cfg" and
  ## add each client line by line, like this:
  ## common-name 10.10.0.13
  ##
  ## Just 1 spelling mistake can make at least
  ## 1 client entry invalid, i.e. this
  ## emergency recovery wouldn't work.
  ##
  ## Once done, run:
  ## ./ovpn_staticIP_giver.jl emergency
  function iterClients()
    clientConfigDir = clientConfigDir
    clients = open("$clientConfigDirclients.cfg")
    for line in eachline(clients)
      #TODO
      # read common-name
      # split by space
      # read IP
      # write single config file
    end
  end
  try
    cfg = open("ovpn_staticIP_giver.cfg", "r")
    clientConfigDir = readline(cfg)
    close(cfg)
    
  catch
    clientConfigDir = "/var/etc/openvpn/ccd"
  end
elseif length(ARGS) == 0
  println("placeholder")
end
