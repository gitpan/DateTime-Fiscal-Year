use Test::More tests => 1;

use DateTime;
use DateTime::Fiscal::Year;

use strict;
# See if we get a valid object
{
my $sf = DateTime->new(year => 2003, month=> 02, day=>01);
my $td = DateTime->new(year => 2003, month=> 03, day=>01);

my $dtfy = DateTime::Fiscal::Year->new(fiscal_start => $sf, target_date => $td);

isa_ok( $dtfy, 'DateTime::Fiscal::Year' );
}
