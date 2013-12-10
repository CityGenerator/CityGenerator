class iptables {
  include iptables::install, iptables::config, iptables::service
}
