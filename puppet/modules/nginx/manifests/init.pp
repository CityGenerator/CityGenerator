class nginx {
  include nginx::install, nginx::config, nginx::service
}
