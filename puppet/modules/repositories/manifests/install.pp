class repositories::install {

    yumrepo { "vmware":
        baseurl => "http://packages.vmware.com/tools/esx/latest/rhel6/x86_64",
        descr => "vmware",
        enabled => 1,
        gpgcheck => 1,
        gpgkey=> 'http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub',
    }

    yumrepo { "epel":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/x86_64",
        descr => "Extra Packages for Enterprise Linux 6",
        enabled => 1,
        gpgcheck => 1,
        gpgkey=> 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
    }

    yumrepo { "epel-debuginfo":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/x86_64/debug",
        descr => "Extra Packages for Enterprise Linux 6 debug info",
        enabled => 0,
        gpgcheck => 1,
        gpgkey=> 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
    }

    yumrepo { "epel-source":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/SRPMS",
        descr => "Extra Packages for Enterprise Linux 6 - x86_64 - Source",
        enabled => 0,
        gpgcheck => 1,
        gpgkey=> 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
    }
    yumrepo { "jenkins":
        baseurl => "http://pkg.jenkins-ci.org/redhat/",
        descr => "Jenkins Repo",
        enabled => 1,
        gpgcheck => 1,
        gpgkey=> 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
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


	yumrepo { "puppetlabs-devel":
		descr=> 'Puppet Labs Devel El 6 - x86_64',
		baseurl=> 'http://yum.puppetlabs.com/el/6/devel/x86_64',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 0,
		gpgcheck=> 1,
    }


	yumrepo { "puppetlabs-products-source":
		descr=> 'Puppet Labs Products El 6 - x86_64 - Source',
		baseurl=> 'http://yum.puppetlabs.com/el/6/products/SRPMS',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 0,
		gpgcheck=> 1,
    }


	yumrepo { "puppetlabs-deps-source":
		descr=> 'Puppet Labs Source Dependencies El 6 - x86_64 - Source',
		baseurl=> 'http://yum.puppetlabs.com/el/6/dependencies/SRPMS',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 0,
		gpgcheck=> 1,
    }


	yumrepo { "puppetlabs-devel-source":
		descr=> 'Puppet Labs Devel El 6 - x86_64 - Source',
		baseurl=> 'http://yum.puppetlabs.com/el/6/devel/SRPMS',
		gpgkey=> 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
		enabled=> 0,
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

	yumrepo { "rpmforge-testing":
		descr=> 'RHEL $releasever - RPMforge.net - testing',
		baseurl=> 'http://apt.sw.be/redhat/el6/en/x86_64/testing',
		enabled=> 0,
		protect=> 0,
		gpgkey=> 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
		gpgcheck=> 1,
    }

	yumrepo { "sonar":
		descr=> 'Sonar',
		baseurl=> 'http://downloads.sourceforge.net/project/sonar-pkg/rpm',
		gpgcheck=> 0,
    }


	yumrepo { "vmware-tools":
		descr=> 'VMware Tools',
		baseurl=> 'http://packages.vmware.com/tools/esx/4.1u1/rhel6/x86_64',
		enabled=> 1,
		gpgcheck=> 1,
    }


}
