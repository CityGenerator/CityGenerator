class httpd::install {

    package{ ["httpd"]:
        ensure =>present,
    }
}
