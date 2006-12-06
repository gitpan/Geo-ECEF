package geo::ecef;


=head1 NAME

geo::ecef - Functions for calculating ecef coordinates from lla

=head1 SYNOPSIS

  use geo::ecef;
  ($lat,$lon,height)=(60,45,0); # Decimal degrees and height in meters
  $x=X($lat,$lon,height);
  $y=Y($lat,$lon,height);
  $z=Z($lat,$lon,height);

  # proj4 output
  
  @p4=split/\s/,'30d44\'15.43"N 55d16\'12.33"E';
  $lat=p2dd($p4[0]);
  $lon=p2dd($p4[1]);


=head1 DESCRIPTION

geo::ecef contains functions for calculating the X,Y and Z coordinates in the 
ecef (earth centered earth fixed) coordinate system from latitude, longitude 
and height information. The wgs84 ellepsoide is used as a basis for the 
calculation.

In addition, geo::ecef contains an utilty function to read output from the 
proj4 projection utility

The formulaes were found at http://www.u-blox.ch.

=head2 Methods


=cut



use strict;
our $VERSION='1.0.0';
use Exporter;
use Math::Big qw/sin cos pi/;
use Math::BigFloat;
#Math::BigFloat->precision(20);
# This causes the checking modules to fail, why?
our @ISA = qw/ Exporter /;
our @EXPORT = qw / X Y Z p2dd/;
our @EXPORTOK = qw /$A $B/;
use Carp;
use warnings;
my($PI,$F,$E,$E2);
$PI=pi(20);
# WGS84:
our($A,$B);
our($ellps)="WGS84";
if ($ellps eq "WGS84"){
  $A =new Math::BigFloat '6378137.00000';
  $B =new Math::BigFloat '6356752.31424518';
  $F =new Math::BigFloat 1/'298.257223563';

}
if ($ellps eq "NAD83"){
  $A =new Math::BigFloat '6378137.00000';
  $B =new Math::BigFloat '6356752.0000';
  $F =new Math::BigFloat 1/'298.57';
}

if ($ellps eq "TEST"){
  $A =2;
  $B =1.5;
  $F = 1-(1.5/2);
}
# http://www.ga.gov.au/nmd/geodesy/datums/wgs.jsp
$E = sqrt(($A**2 - $B**2)/$A**2);
$E2= sqrt(($A**2 - $B**2)/$B**2);

# This program converts LLA (latitude, longitude, altitude) locations 
# into the ECEF (Earth Centered Earth Fixed) coordinate system
# The formulaes were found at http://www.u-blox.ch.

# Morten Sickel,
# Norwegian Radiation Protection Authority

# parameters from WGS84

sub _checkdeg{
  my ($lat,$lon)=@_;
  return('invalid latitude (outside [-90,90])') if abs($lat) > $PI;
  return('invalid longitude (outside [-180,180]') if abs($lon) > 2*$PI;
  return(undef);
}

sub _dtr{
  return $_[0]/180.0*$PI
}

sub _N{
  my $lat=shift;
  my $n= $A / sqrt(1-(($E**2)*(sin($lat)**2)));
  return($n);
}



=head3 X

  X($lat,$lon,$height,$rad)

calculates the ecef X-coordinate from the latitude, longitude and height. 
The lat and lon is considered beeing degrees, unless $rad is set to a true 
value, in which case they are considered to be radianes.


=cut


sub X{
  my ($lat,$lon,$h,$rad)=@_;
  $lat=_dtr($lat) unless $rad;
  $lon=_dtr($lon) unless $rad;
  carp(_checkdeg($lat,$lon)) if _checkdeg($lat,$lon);
  return (_N($lat)+$h)*cos($lat)*cos($lon);
}

=head3 Y

calculates the Y-coordinate, else similiar to X()

=cut

sub Y{
  my ($lat,$lon,$h,$rad)=@_;
  $lat=_dtr($lat) unless $rad;
  $lon=_dtr($lon) unless $rad;
  carp(_checkdeg($lat,$lon)) if _checkdeg($lat,$lon);
  return (_N($lat)+$h)*cos($lat)*sin($lon);
}

=head3 Z

calculates the Z-coordinate, else similiar to X()

=cut

sub Z{
  my ($lat,$lon,$h,$rad)=@_;
  $lat=_dtr($lat) unless $rad;
  $lon=_dtr($lon) unless $rad;  
  carp(_checkdeg($lat,$lon)) if _checkdeg($lat,$lon);
  return((( $B**2/ $A**2 * _N($lat))+$h)*sin($lat));
}

=head3 p2dd()

p2dd takes a latitude or longitude as output by proj4 and converts it to
decimal degrees. The input format is on the form  71d3'56.623"N. undef is 
returned for invalid values, i.e. min or sec >= 60.

=cut

#'

sub p2dd{
# DMS Coordinates as given out by proj V4
# eg 71d3'56.623"N  
# or 71d3'N
# or 71dN
# May use NSEW, S and W coordinates should be negative
  my $coord=shift;
  $coord=~/(\d+)d(\d+\'(\d+\.?\d*\")?)?(E|W|N|S)/;
  no warnings;
# May get some undefined value varnings. 
  my $deg= $1;
  my $min= $2 if $2*1;
  my $sek= $3 if $3*1;
  my $quad= $4 || $3 || $2;
  my $sign= 2*($quad =~tr/NE/NE/)-1;
  # Sign is 1 for N or E, -1 for others i.e S or W
  return undef if ($min>=60 || $sek >= 60);
# This should not happen when reading proj4 data, but just in case
  $deg=$sign*($deg+$min/60+$sek/3600);
  use warnings;
}

1;

=head1 LICENCE

This program is free software; you may redistribute it and/or modify it 
under the same terms as Perl itself.

=head1 AUTHORS

(c) by Morten Sickel http://sickel.net/ 2005

=cut
