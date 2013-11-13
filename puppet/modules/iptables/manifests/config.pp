class iptables::config {
    file { "/etc/sysconfig/iptables":
        ensure  =>"file",
        mode    =>0755,
        content =>template("iptables/iptables.erb"),
        require =>Class['iptables::install'],
        notify  =>Class['iptables::service'],
    }
}
