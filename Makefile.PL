use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Geo::ECEF',
    VERSION_FROM      => 'lib/Geo/ECEF.pm',
    PREREQ_PM         => {
                          Geo::Functions    => 0.02,
                          Geo::Ellipsoids   => 0.06,
                         },
    ($] >= 5.005 ? 
      (ABSTRACT_FROM  => 'lib/Geo/ECEF.pm',
       AUTHOR         => 'Morten Sickel <morten@sickel.net> & Michael R. Davis (mrdvt92)') : ()),
);
