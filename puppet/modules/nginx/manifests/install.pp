class nginx::install {

    package{ "nginx":
        ensure =>present,
    }
}
