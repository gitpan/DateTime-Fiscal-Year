use Test::More tests => 2;

use DateTime;
use DateTime::Fiscal::Year;

use strict;
# Calculate Period of Fiscal Year
{
my $sf = DateTime->new(year => 2003, month=> 02, day=>01);
my $td = DateTime->new(year => 2003, month=> 04, day=>01);

my $dtfy = DateTime::Fiscal::Year->new(fiscal_start => $sf, target_date => $td);

is( $dtfy->period_of_fiscal_year(12), 3,		'Period of Fiscal Year' );
is( $dtfy->quarter_of_fiscal_year, 1, 			'Quarter Fiscal Year' );
}
