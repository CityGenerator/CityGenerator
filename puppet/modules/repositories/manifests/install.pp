class repositories::install {

    yumrepo { "epel":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/x86_64",
        descr => "Extra Packages for Enterprise Linux 6",
        enabled => 1,
        gpgcheck => 1,
        gpgkey=> 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
    }

	yumrepo { "puppetlabs-products":
		descr=> 'Puppet Labs Products El 6 - x86_64',
		baseurl=> 'http://yum.puppetlabs.com/el/6/products/x86_64',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 1,
		gpgcheck=> 1,
    }

	yumrepo { "puppetlabs-deps":
		descr=> 'Puppet Labs Dependencies El 6 - x86_64',
		baseurl=> 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 1,
		gpgcheck=> 1,
    }

	yumrepo { "rpmforge":
		descr=> 'RHEL $releasever - RPMforge.net - dag',
		baseurl=> 'http://apt.sw.be/redhat/el6/en/x86_64/rpmforge',
		enabled=> 1,
		protect=> 0,
		gpgkey=> 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
		gpgcheck=> 1,
    }

	yumrepo { "rpmforge-extras":
		descr=> 'RHEL $releasever - RPMforge.net - extras',
		baseurl=> 'http://apt.sw.be/redhat/el6/en/x86_64/extras',
		enabled=> 0,
		protect=> 0,
		gpgkey=> 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
		gpgcheck=> 1,
    }

}
