use Test::More;
use Modern::Perl;
use Data::Printer alias => 'pdump';

use lib 't/';
use Local::Ansible::Test2;

#########################################

use_ok('Ansible::Util::Vars');

my $vars = Ansible::Util::Vars->new;
isa_ok( $vars, 'Ansible::Util::Vars' );
ok( $vars->clearCache );   

my $test2 = Local::Ansible::Test2->new;

SKIP: {
	skip "ansible-playbook executable not found"
	  unless $test2->ansiblePlaybookExeExists;

	$test2->chdir;

    my $href;
    eval {
    	$href = $vars->getVars( ['states'] );
    };
    ok($@);
  
    $vars->vaultPasswordFiles( $test2->vaultPasswordFiles );
   
	getVars($vars);
	getVar($vars);
	getValue($vars);

    #
    # ensure tempfile cleanup worked
    #
	my @files = @{ $vars->_tempFiles };
	$vars = undef;
	
	foreach my $file (@files) {
		ok( !-f $file );
	}
}

done_testing();

#############################################

sub getVars {
	my $vars = shift;

	my $href = $vars->getVars( ['states'] );
	ok( exists $href->{states} );

	eval { $vars->getVars; };
	ok($@);
}

sub getVar {
	my $vars = shift;

	my $href = $vars->getVar('states.iowa');
	my @keys = keys %{ $href->{states} };
	ok( @keys == 1 );

	$href = $vars->getVar('states.texas');
	@keys = keys %{ $href->{states} };
	ok( @keys == 1 );

	$href = $vars->getVar('states.iowa.cities');
	ok( ref( $href->{states}->{iowa}->{cities} ) eq 'ARRAY' );

	$href = $vars->getVar('states.iowa.cities.0');
	ok( ref( $href->{states}->{iowa}->{cities}->[0] ) eq 'HASH' );

	$href = $vars->getVar('states.iowa.cities.0.zip_codes.0');
	ok( $href->{states}->{iowa}->{cities}->[0]->{zip_codes}->[0] eq '52001' );

	eval { $vars->getVar; };
	ok($@);
}

sub getValue {
	my $vars = shift;

	my $val = $vars->getValue('states.iowa.cities.0.zip_codes.0');
	ok( $val eq '52001' );

	eval { $vars->getValue; };
	ok($@);
}
