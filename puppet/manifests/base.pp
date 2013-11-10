node default {

    #include nginx
    include iptables
    include users
    include httpd
    include repositories
}

