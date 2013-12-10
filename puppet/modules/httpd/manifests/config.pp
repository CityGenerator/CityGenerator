class httpd::config {
    file { "/etc/httpd/conf/httpd.conf":
        ensure  =>"file",
        mode    =>0755,
        content =>template("httpd/httpd.conf.erb"),
        require =>Class['httpd::install'],
        notify  =>Class['httpd::service'],
    }
}
