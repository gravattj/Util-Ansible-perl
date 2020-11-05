package Ansible::Util::Run;

=head1 NAME

Ansible::Util::Run - Wrapper for Ansible CLI commands.

=cut

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Kavorka 'method';
use Data::Printer alias => 'pdump';

with 'Ansible::Util::Roles::Constants';

##############################################################################
# PUBLIC ATTRIBUTES
##############################################################################

with
  'Ansible::Util::Roles::Attr::VaultPasswordFiles',
  'Util::Medley::Roles::Attributes::Spawn';

##############################################################################
# PRIVATE_ATTRIBUTES
##############################################################################

##############################################################################
# CONSTRUCTOR
##############################################################################

##############################################################################
# PUBLIC METHODS
##############################################################################

method ansiblePlaybook (Str           :$playbook,
                        ArrayRef[Str] :$extraArgs,
                        Bool          :$confessOnError = 1,
                        Bool          :$wantArrayRefs = 0) {

	my @cmd;
	push @cmd, CMD_ANSIBLE_PLAYBOOK();
	push @cmd, $self->_getVaultPasswordArgs;
	push @cmd, @$extraArgs if $extraArgs;
	push @cmd, $playbook if $playbook;

	my ( $stdout, $stderr, $exit ) =
	  $self->Spawn->capture( cmd => \@cmd, wantArrayRefs => $wantArrayRefs );
	if ( $exit and $confessOnError ) {
		confess $stderr;
	}

	return ( $stdout, $stderr, $exit );
}

##############################################################################
# PRIVATE METHODS
##############################################################################

method _getVaultPasswordArgs {

	my @args;
	foreach my $file ( @{ $self->vaultPasswordFiles } ) {
		push @args, ARGS_VAULT_PASS_FILE(), $file;
	}

	return @args;
}

1;
