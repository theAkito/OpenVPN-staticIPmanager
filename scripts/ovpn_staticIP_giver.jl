#!/usr/bin/env julia
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>

using Dates

let clientConfigDir::String end

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
    exit(1)
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
  global clientConfigDir = "/var/etc/openvpn/ccd"
  function emergeClients()
    println("Run emergency mode?!")
    println("If client-config files exist, they will be overwritten!")
    print("Enter YES if you agree: ")
    agreement = readline(stdin)
    if agreement == "YES"
      println("Starting recovery...")
    else
      println("Request denied. Exiting.")
      exit(1)
    end
    clients = open("$clientConfigDir/clients.cfg")
    for line in eachline(clients)
      ## Reads a config called "clients.cfg" which location
      ## is either specified in "ovpn_staticIP_giver.cfg"
      ## or defaults to "/var/etc/openvpn/ccd".
      ##
      ## Iterates through the whole list of client/IP
      ## pairs and generates their respective configs
      ## to re-enable their static IPs.
      lineArray = split(line, " ")
      commonName = lineArray[1]
      ipAddress = lineArray[2]
      clientConfig = open("$clientConfigDir/$commonName", "w")
      write(clientConfig, "ifconfig-push $ipAddress $ipAddress")
      close(clientConfig)
    end
  end
  try
    cfg = open("ovpn_staticIP_giver.cfg", "r")
    global clientConfigDir = readline(cfg)
    close(cfg)
    emergeClients()
  catch
    emergeClients()
  end
elseif length(ARGS) >= 1 && ARGS[1] == "add"
  #TODO add entry and log static IP address to "static_IPs.cfg"
#  function checkDup()
elseif length(ARGS) >= 1 && ARGS[1] == "remove"
  #TODO remove entry from "static_IPs.cfg" and free the static IP address
elseif length(ARGS) >= 1 && ARGS[1] == "help"
  #TODO print usage help
elseif length(ARGS) == 0
  #TODO print usage help
  println("No arguments provided.")
end
