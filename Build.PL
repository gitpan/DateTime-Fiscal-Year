use Module::Build;

my $build = new Module::Build
 (
  module_name => 'DateTime::Fiscal::Year',
  license => 'perl',
  requires => {
	perl		=> '5.6.1',
	DateTime	=> '0.07',
	},
 );

$build->create_build_script();

