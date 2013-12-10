class nginx::service {
    service { "nginx":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        enable => true,
        require => Class["nginx::config"],
    }
}

