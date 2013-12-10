class iptables::install {
  
    package{ ["iptables"]:
        ensure =>present,
    }
}
