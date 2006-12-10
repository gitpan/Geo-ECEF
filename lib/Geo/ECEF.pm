package Geo::ECEF;

=head1 NAME

Geo::ECEF - Converts between ECEF (earth centered earth fixed) coordinates and latitude, longitude and height above ellipsoid.

=head1 SYNOPSIS

  use Geo::ECEF;
  my $obj=Geo::ECEF->new(); #WGS84 is the default
  my ($x, $y, $z)=$obj->ecef(39.197807, -77.108574, 55); #Lat (deg), Lon (deg), HAE (meters)
  print "X: $x\tY: $y\tZ: $z\n";

  my ($lat, $lon, $hae)=$obj->geodetic($x, $y, $z); #X (meters), Y (meters), Z (meters)
  print "Lat: $lat  \tLon: $lon \tHAE $hae\n";


=head1 DESCRIPTION

Geo::ECEF provides two methods ecef and geodetic.  The ecef method calculates the X,Y and Z coordinates in the ECEF (earth centered earth fixed) coordinate system from latitude, longitude and height above the ellipsoid.  The geodetic method calculates the latitude, longitude and height above ellipsoid from ECEF coordinates.

The formulas were found at http://www.u-blox.ch/ and http://waas.stanford.edu/~wwu/maast/maastWWW1_0.zip.

This code is an object Perl rewrite of a similar package by Morten Sickel, Norwegian Radiation Protection Authority

=cut

use strict;
use vars qw($VERSION);
use Geo::Ellipsoids;
use Geo::Functions qw{rad_deg deg_rad};

$VERSION = sprintf("%d.%02d", q{Revision: 0.06} =~ /(\d+)\.(\d+)/);

=head1 CONSTRUCTOR

=head2 new

The new() constructor initializes the ellipsoid method.

  my $obj=Geo::ECEF->new("WGS84"); #WGS84 is the default

=cut

sub new {
  my $this = shift();
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->initialize(@_);
  return $self;
}

=head1 METHODS

=cut

sub initialize {
  my $self = shift();
  my $param = shift()||undef();
  $self->ellipsoid($param);
}

=head2 ellipsoid

Method to set or retrieve the current ellipsoid object.  The ellipsoid is a Geo::Ellipsoids object.

  my $ellipsoid=$obj->ellipsoid;  #Default is WGS84

  $obj->ellipsoid('Clarke 1866'); #Built in ellipsoids from Geo::Ellipsoids
  $obj->ellipsoid({a=>1});        #Custom Sphere 1 unit radius

=cut

sub ellipsoid {
  my $self = shift();
  if (@_) {
    my $param=shift();
    use Geo::Ellipsoids;
    my $obj=Geo::Ellipsoids->new($param);
    $self->{'ellipsoid'}=$obj;
  }
  return $self->{'ellipsoid'};
}

=head2 ecef

Method returns X (meters), Y (meters), Z (meters) from lat (degrees), lon (degrees), HAE (meters).

  my ($x, $y, $z)=$obj->ecef(39.197807, -77.108574, 55);

=cut

sub ecef {
  my $self = shift();
  my $lat_rad=rad_deg(shift()||0);
  my $lon_rad=rad_deg(shift()||0);
  my $hae=shift()||0;
  return $self->ecef_rad($lat_rad, $lon_rad, $hae);
}

=head2 ecef_rad

Method returns X (meters), Y (meters), Z (meters) from lat (radians), lon (radians), HAE (meters).

  my ($x, $y, $z)=$obj->ecef(0.678, -0.234, 55);

=cut

sub ecef_rad {
  my $self = shift();
  my $lat=shift()||0;
  my $lon=shift()||0;
  my $hae=shift()||0;
  my $ellipsoid=$self->ellipsoid;
  my $n=$ellipsoid->n_rad($lat);
  my $x=($n+$hae)*cos($lat)*cos($lon);
  my $y=($n+$hae)*cos($lat)*sin($lon);
  my $z=((( $ellipsoid->b**2 / $ellipsoid->a**2 * $n)+$hae)*sin($lat));
  return($x, $y, $z);
}

=head2 geodetic

Method returns latitude (degrees), longitude (degrees), HAE (meters) from X (meters), Y (meters), Z (meters).

  my ($lat, $lon, $hae)=$obj->geodetic($x, $y, $z);

Portions of this method maybe 

 *************************************************************************
 *     Copyright c 2001 The board of trustees of the Leland Stanford     *
 *                      Junior University. All rights reserved.          *
 *     This script file may be distributed and used freely, provided     *
 *     this copyright notice is always kept with it.                     *
 *                                                                       *
 *     Questions and comments should be directed to Todd Walter at:      *
 *     twalter@stanford.edu                                              *
 *************************************************************************

=cut

sub geodetic {
  my $self = shift();
  my $x=shift()||0;
  my $y=shift()||0;
  my $z=shift()||0;
  my $ellipsoid=$self->ellipsoid;
  my $e2=$ellipsoid->e2;
  my $p=sqrt($x**2 + $y**2);
  my $lon=atan2($y,$x);
  my $lat=atan2($z/$p, 0.01);
  my $n=$ellipsoid->n_rad($lat);
  my $hae=$p/cos($lat) - $n;
  my $old_hae=-1e-9;
  my $num=$z/$p;
  while (abs($hae-$old_hae) > 1e-4) {
    $old_hae=$hae;
    my $den=1 - $e2 * $n /($n + $hae);
    $lat=atan2($num, $den);
    $n=$ellipsoid->n_rad($lat);
    $hae=$p/cos($lat)-$n;
  }
  $lat=deg_rad($lat);
  $lon=deg_rad($lon);
  return($lat, $lon, $hae);
}

1;

__END__

=head1 TODO

=head1 BUGS

Please send to the geo-perl email list.

=head1 LIMITS

=head1 AUTHORS

Michael R. Davis qw/perl michaelrdavis com/

Morten Sickel http://sickel.net/

=head1 LICENSE

Copyright (c) 2006 Michael R. Davis (mrdvt92)

Copyright (c) 2005 Morten Sickel (sickel.net)

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

geo::ecef
Astro::Coord::ECI
http://www.ngs.noaa.gov/cgi-bin/xyz_getxyz.prl
