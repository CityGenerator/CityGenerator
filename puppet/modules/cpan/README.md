puppet-cpan
===========

Handle installations of cpan modules via puppet.

Usage Example
-------------

    cpan { "Clone::Closure":
      ensure => present
    }
