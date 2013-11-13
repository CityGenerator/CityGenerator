node default {

    #include nginx
    include cpan
    include iptables
    include users
    include httpd
    include repositories
}

