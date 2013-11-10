class httpd::install {

    package{ ["httpd",'perl-CGI','perl-XML-Simple', 'perl-Template-Toolkit','perl-JSON','perl-Lingua-EN-Inflect', 'perl-Lingua-EN-Numericalize', 'perl-Lingua-EN-Inflect-Number', 'perl-Test-Harness']:
        ensure =>present,
    }
}
