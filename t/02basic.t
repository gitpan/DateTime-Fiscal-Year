use Test::More tests => 6;

use DateTime;
use DateTime::Fiscal::Year;
use strict;

# Jan 01 non-leap year as 1st day
{
my $sfy = DateTime->new(year => 2003, month=> 01, day=>01);
my $td	= DateTime->new(year => 2003, month=> 01, day=>01);

my $dtfy = DateTime::Fiscal::Year->new(fiscal_start => $sfy, target_date => $td);

is( $dtfy->day_of_fiscal_year, 1,	'January 1 as day 1 non-leap' );
is( $dtfy->week_of_fiscal_year, 1, 	'January 1 as day 1 non-leap week 1' );
}

# Dec 31 non-leap as last day
{
my $sfy = DateTime->new(year => 2003, month=> 01, day=>01);
my $td	= DateTime->new(year => 2003, month=> 12, day=>31);

my $dtfy = DateTime::Fiscal::Year->new(fiscal_start => $sfy, target_date => $td);

is( $dtfy->day_of_fiscal_year, 365,		'December 31 as day 365 non-leap' ); 
is( $dtfy->week_of_fiscal_year, 52, 		'December 31 as day 365 non-leap week 52' ); 
}

# Dec 31 of leap year 
{
my $sfy = DateTime->new(year => 2004, month=> 01, day=>01);
my $td	= DateTime->new(year => 2004, month=> 12, day=>31);

my $dtfy = DateTime::Fiscal::Year->new(fiscal_start => $sfy, target_date => $td);

is( $dtfy->day_of_fiscal_year, 366,		'December 31 as day 366 leap' ); 
is( $dtfy->week_of_fiscal_year, 52, 		'December 31 as day 366 leap week 52' ); 
}


