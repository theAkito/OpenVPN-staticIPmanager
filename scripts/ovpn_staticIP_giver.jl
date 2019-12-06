#!/usr/bin/env julia
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>

using Dates

let clientConfigDir::String,                ## client-config-dir set in OpenVPN Server config.
    originalIpAddressArray::Array{Int64, 4} ## Starting point in IP address iteration.
end

#clientConfigDir = "/var/etc/openvpn/ccd"
# Debugging
clientConfigDir = "/home/akito/src/julia-serving-hookers/tmp"

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
  global clientConfigDir
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
    close(clients)
  end
  try
    cfg = open("ovpn_staticIP_giver.cfg", "r")
    global clientConfigDir = readline(cfg)
    close(cfg)
    emergeClients()
  catch
    emergeClients()
  end
elseif length(ARGS) == 2 && ARGS[1] == "add"
  ## Adds client by common-name and automatically
  ## assigns an available static IP address
  ## permanently to that client.
  ##
  ###  Usage
  ## ./ovpn_staticIP_giver.jl add common-name
  global clientConfigDir
  global originalIpAddressArray = [10, 148, 0, 14]
  commonName = ARGS[2]
  clients = open("$clientConfigDir/clients.cfg", "r+")
  clientConfig = open("$clientConfigDir/$commonName", "w+")
  ipAddressArray = originalIpAddressArray
  newIpAddressArray = originalIpAddressArray
  function assignIP()
    position = 4
    ipArc = 0
    function findNextFreeIP(position, tempIpAddressArray)
      ipArc = tempIpAddressArray[position]
      if position <= -1
        println("Assigning invalid address.")
        exit(1)
      elseif position == 1 && ipArc < 10
        println("Ran out of IP addresses.")
        exit(1)
      end
      if ipArc == ipAddressArray[position] && ipArc < 255
        tempIpAddressArray[position] = ipArc += 1
      elseif ipArc >= 255
        tempIpAddressArray[position] = 1
        position -= 1
        findNextFreeIP(position, tempIpAddressArray)
      end
      return tempIpAddressArray
    end
    function doubleCheckAssignment()
      ## Just before assigning the new static
      ## IP address, it double checks against
      ## every entry, if it is already registered.
      for line in eachline(clients)
        lineArray = split(line, " ")
        cn = lineArray[1]
        ipAddress = lineArray[2]
        tempIpAddressArray = parse.(Int64, split(ipAddress, "."))
        if newIpAddressArray == tempIpAddressArray
          println("Assignment invalid.")
          println("Address already assigned. Exiting.")
          exit(1)
        elseif cn == commonName
          println("Assignment invalid.")
          println("This Common Name is already registered. Exiting.")
          exit(1)
        end
      end
    end
    for line in eachline(clients)
      ## Reads a config called "clients.cfg" which location
      ## is either specified in "ovpn_staticIP_giver.cfg"
      ## or defaults to "/var/etc/openvpn/ccd".
      ##
      ## Iterates through the whole list of client/IP
      ## pairs and generates their respective configs
      ## to re-enable their static IPs.
      global newIpAddressArray
      lineArray = split(line, " ")
      cn = lineArray[1] ## Just to prevent commonName i.e. client duplication.
      ipAddress = lineArray[2] ## This line's IP address read from cofig file.
      ipAddressArray = parse.(Int64, split(ipAddress, ".")) ## Converts read IP address to Array of Ints.
      if ipAddressArray == ""
        ## Ignore empty lines.
        continue
      elseif commonName == cn
        ## Double check to prevent entry duplication.
        println("Client registered already.")
        try
          ## If a file exists and commonName is set in clients.cfg,
          ## then client is definitely assigned a static IP.
          f = open("$clientConfigDir/$commonName", "r")
          close(f)
          println("Client config file present.")
        catch
          ## Both the common-name has to be in the clients.cfg
          ## and the $commonName client config file must be present.
          ## If one is missing, something is not right.
          println("Client registered already, but config file is missing.")
          println("This needs manual fixing.")
          exit(1)
        finally
          println("Client already exists. Exiting.")
          exit(1)
        end
      elseif newIpAddressArray == ipAddressArray
        ## findNextFreeIP continues iterating until an IP
        ## is found that has not been registered before.
        global newIpAddressArray = findNextFreeIP(position, newIpAddressArray)
        continue
      end
    end
    ## Actual assignment of new static IP addresses
    doubleCheckAssignment()
    firstByte = newIpAddressArray[1]
    secondByte = newIpAddressArray[2]
    thirdByte = newIpAddressArray[3]
    fourthByte = newIpAddressArray[4]
    ipAddressArray = "$firstByte.$secondByte.$thirdByte.$fourthByte"
    write(clientConfig, "ifconfig-push $ipAddressArray $ipAddressArray\n")
    println("Assigned $ipAddressArray to $commonName !")
    write(clients, "$commonName $ipAddressArray\n")
    println("Added $commonName to $clientConfigDir/clients.cfg !")
    close(clientConfig)
    close(clients)
  end
  assignIP()
elseif length(ARGS) >= 1 && ARGS[1] == "remove"
  #TODO remove entry from "static_IPs.cfg" and free the static IP address
  println("Not implemented yet.")
elseif length(ARGS) >= 1 && ARGS[1] == "help"
  #TODO print usage help
  println("Not implemented yet.")
elseif length(ARGS) == 0
  #TODO print usage help
  println("No arguments provided.")
end
