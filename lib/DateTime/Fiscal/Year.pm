package DateTime::Fiscal::Year;

use strict;

use DateTime;
use Params::Validate qw( validate );

use vars qw($VERSION);

$VERSION = '0.01';

my ( @MonthLengths, @LeapYearMonthLengths );

BEGIN {
	@MonthLengths =
		( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

	@LeapYearMonthLengths = @MonthLengths;
	$LeapYearMonthLengths[1]++;
}

sub new {
	my $class = shift;
	my %args = validate( @_, { fiscal_start => { isa => 'DateTime' },
                                   target_date  => { isa => 'DateTime' },
                                 } );
	my $self = {
		fiscal_start => $args{fiscal_start},
		target_date => $args{target_date}
		};
	
	bless $self, $class;
	return $self;
}

sub day_of_fiscal_year {
	my $self = shift;

	return $self->{day_of_fiscal_year} if defined($self->{day_of_fiscal_year});

	my $dofy;
	 
#	my $fmo = (( $self->{sfy}->month == 1 ) ? 0 : 1 );  	these were needed for Days_in_Year from Date::Calc but
#	my $index = ( $self->{sfy}->month - $fmo );		dont seem to have any function here! 

	my $offset = ($self->{fiscal_start}->day_of_year);

	my $dify = ( $self->{fiscal_start}->is_leap_year ? 366 : 365 );	# days in fiscal year; if the fiscal start is not 01-01 this should be incremented elsewhere, the components or fiscal start 02-01 and the fiscal year we want 2004
	my $doy	= $self->{target_date}->day_of_year;	# day of year

	if ( $doy >= $offset ) { $dofy = ( $doy - $offset + 1  ); } else { $dofy = (( $dify - $offset) + $doy + 1); }
	$self->{day_of_fiscal_year} = $dofy;
}

sub week_of_fiscal_year {
	my $self = shift;
	
	return $self->{week_of_fiscal_year} if defined($self->{week_of_fiscal_year});

	my $wofy;

	$wofy = $self->day_of_fiscal_year / 7;
	$wofy = ( $wofy == int($wofy) ? $wofy : int($wofy + 1) );
	if ($wofy == 53 ) { $wofy = 52 ;}
	$self->{week_of_fiscal_year} = $wofy;
	 			
}

sub period_of_fiscal_year {
	my $self = shift;

	return $self->{period_of_fiscal_year} if defined($self->{period_of_fiscal_year});

	$self->{number_of_fiscal_periods} = shift;
	
	$self->_align_fiscal_periods;

	if ( $self->{number_of_fiscal_periods} == 12 ) {
		$self->{period_of_fiscal_year} = $self->_period_index;
		$self->{period_of_fiscal_year}++ if ( $self->{fiscal_start}->month == 1 );
	}

	if ( $self->{number_of_fiscal_periods} == 13 ) {
		$self->{period_of_fiscal_year} = $self->{fiscal_periods}->[$self->week_of_fiscal_year];
	}

	$self->{period_of_fiscal_year};
}

sub quarter_of_fiscal_year {
	my $self = shift;

	if ( $self->{number_of_fiscal_periods} == 12 ) { 
		return $self->{quarter_of_fiscal_year} = int((( $self->{period_of_fiscal_year} - 1)/3) + 1); 
	}

	if ( $self->{number_of_fiscal_periods} == 13 ) {
		return $self->{quarter_of_fiscal_year} = int((( $self->{period_of_fiscal_year} - 1)/4) + 1);
	}	
}

sub _align_fiscal_periods {
	my $self = shift;

	if ( $self->{number_of_fiscal_periods} == 12 ) {
		my @periods = $self->{fiscal_start}->is_leap_year ? @LeapYearMonthLengths : @MonthLengths;
			for ( my $i = 1; $i < $self->{fiscal_start}->month; $i++ ) {
				push @periods, shift @periods;
			}
		push @periods, 0;
		for ( my $i = 0; $i <= $#periods; $i++ ) {
			$periods[$i] += $periods[$i - 1];
		}
		unshift @periods, 0;
		$self->{fiscal_periods} = \@periods;
	};

	if ( $self->{number_of_fiscal_periods} == 13 ) {
		my @periods = 0;
		my $counter = 0;
		my $period_index = 1;

		for ( my $i = 1; $i <= 52; $i++, $counter++ ) {
			if ( $counter == 4 ) { $counter = 0; $period_index++; }
			$periods[$i] = $period_index;
		}
		$self->{fiscal_periods} = \@periods;
	}
	$self->{fiscal_periods};
}

sub _period_index {
	my $self = shift;

        foreach my $index ( reverse 1..12 ) {
            return $index
		if $self->{fiscal_periods}->[$index - 1] < $self->day_of_fiscal_year;
	}
}

1;

__END__

=head1 NAME

DateTime::Fiscal::Year - Calculate the day or week of the Fiscal Year with an arbitrary start date

=head1 SYNOPSIS

  use DateTime;
  use DateTime::Fiscal::Year;

  my $fs = DateTime->new(year=>2003, month=>02, day=>01);
  my $td = DateTime->new(year=>2003, month=>03, day=>01);

  my $df = DateTime::Fiscal::Year->new(fiscal_start => $fs, target_date => $td);

  $df->day_of_fiscal_year();

	or

  $df->week_of_fiscal_year();

=head1 DESCRIPTION

This module allows you to calulate the day number or week number of a date, given a
start date and a target date. This is often needed in business, where the fiscal year
begins and ends on different days than the calendar year. This module is based on the
Gregorian calendar. Using other DT calendar objects will return results, but the behavior
is unpredicatable for calendars that have more than 365 or 366 days.

=head1 USAGE

This module implements the following methods:

=over 4

=item * new(fiscal_start => $fs, target_date => $td)

Given a valid DateTime object as the fiscal start date and another as
the target date, this method returns a new DateTime::Fiscal::Year
object. The arguments are "fiscal_start" - this is the first day of
the fiscal year; and "target_date" - this is the date you want to know
the day or week number of, in relation to the fiscal_start date.

=item * day_of_fiscal_year()

Returns the day of the fiscal year as calculated from the fiscal_start date and target date of
a valid DateTime::Fiscal::Year object.


  my $fs = DateTime->new(year=>2003, month=>02, day=>01);
  my $td = DateTime->new(year=>2003, month=>03, day=>01);

  my $df = DateTime::Fiscal::Year->new(fiscal_start => $fs, target_date => $td);

  my $dofy = $df->day_of_fiscal_year();

Day of fiscal year ($dofy) is 29. If given the same day for start and target, the value is 1. 

=item * week_of_fiscal_year()

Returns the week of the fiscal year as calculated from the fiscal_start date and target date of
a valid DateTime::Fiscal::Year object.

  my $fs = DateTime->new(year=>2003, month=>02, day=>01);
  my $td = DateTime->new(year=>2003, month=>03, day=>01);

  my $df = DateTime::Fiscal::Year->new(fiscal_start => $fs, target_date => $td);

  my $wofy = $df->week_of_fiscal_year();

Week of fiscal year ($wofy) is 5. There is not a week 0 or 53. This module was built to
assist in financial applications not to satisfy the ISO.

=item * period_of_fiscal_year()

Returns the period of the fiscal year. 

=item * quarter_of_fiscal_year()

Returns the quater of the fiscal year.

=back

=head1 SUPPORT

Support for this module can be obtained from:

datetime@perl.org

=head1 AUTHOR

Jesse Shy <jshy@pona.net>, thanks to Dave Rolsky for being brave enough to start the
perl date-time project. I hope this helps anyone who has to build programs that due
financial date calculations.

=head1 COPYRIGHT

Copyright (c) 2003 Jesse Shy. All rights reserved. This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=head1 SEE ALSO

B<DateTime.pm>, datetime@perl.org mailing list

http://datetime.perl.org

=cut

