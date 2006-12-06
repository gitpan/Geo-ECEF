package Geo::ECEF;

=head1 NAME

Geo::ECEF - Calculates ECEF coordinates (earth centered earth fixed) from latitude, longitude and height above ellipsoid information

=head1 SYNOPSIS

  use Geo::ECEF;
  my $obj=Geo::ECEF->new(); #WGS84 is the default
  my ($x, $y, $z)=$obj->ecef(39.197807, -77.108574, 55); #Lat (deg), Lon (deg), meters (HAE)
  print "X: $x, Y: $y, Z: $z\n";

=head1 DESCRIPTION

Geo::ECEF calculates the X,Y and Z coordinates in the ECEF (earth centered earth fixed) coordinate system from latitude, longitude and height information.

The formulas were found at http://www.u-blox.ch.

This code is an object perl rewrite of a simular package by Morten Sickel, Norwegian Radiation Protection Authority

=cut

use strict;
use vars qw($VERSION);
use Geo::Ellipsoids;
use Geo::Functions qw{rad_deg};

$VERSION = sprintf("%d.%02d", q{Revision: 0.03} =~ /(\d+)\.(\d+)/);

=head1 CONSTRUCTOR

=head2 new

The new() constructor.

  my $obj=Geo::ECEF->new("WGS84"); #WGS84 is default

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
  my $param = shift();
  $self->ellipsoid(Geo::Ellipsoids->new($param));
}

=head2 ecef

Method returns X (meters), Y (meters), Z (meters) from lat (degrees), lon (degrees), HAE (meters).

=cut

sub ecef {
  my $self = shift();
  my $lat=rad_deg(shift()||0);
  my $lon=rad_deg(shift()||0);
  my $hae=shift()||0;
  my $e=$self->ellipsoid;
  my $N=$self->_N($lat);
  my $x=($N+$hae)*cos($lat)*cos($lon);
  my $y=($N+$hae)*cos($lat)*sin($lon);
  my $z=((( $e->b**2 / $e->a**2 * $N)+$hae)*sin($lat));
  return($x, $y, $z);
}

=head2 ellipsoid

Method to set or retrieve the current ellipsoid object.

=cut

sub ellipsoid {
  my $self = shift();
  if (@_) { $self->{'ellipsoid'} = shift() }; #sets value
  return $self->{'ellipsoid'};
}

sub _N {
  my $self=shift();
  my $radians=shift();
  my $e=$self->ellipsoid;
  return $e->a / sqrt(1-(($e->e2)*(sin($radians)**2)));
}

1;

__END__

=head1 TODO

Write functions that convert from ECEF to lla

=head1 BUGS

=head1 LIMITS

=head1 AUTHORS

Michael R. Davis qw/perl michaelrdavis com/
Morten Sickel http://sickel.net/

=head1 LICENSE

Copyright (c) 2006 Michael R. Davis (mrdvt92)
Copyright (c) 2005 Morten Sickel (sickel.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

geo::ecef
