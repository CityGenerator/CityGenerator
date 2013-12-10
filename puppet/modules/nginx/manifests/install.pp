class nginx::install {

    package{ ["nginx", "fcgi-perl"]:
        ensure =>present,
    }
}
