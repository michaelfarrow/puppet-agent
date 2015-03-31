class agent {

	Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

	stage { 'first':
		before => Stage['main'],
	}

	if $::osfamily == 'Debian' {

		exec { "apt-update":
			command => "/usr/bin/apt-get update && touch /tmp/apt-get-updated",
			unless  => "test -e /tmp/apt-get-updated",
		}

		Exec["apt-update"] -> Package <| |>

	}

	class { 'agent::hostname_config':
		stage => 'first',
	}

	if $::agentfqdn != '' {
		$cond_agentfqdn = $::agentfqdn
	} else {
		$cond_agentfqdn = $::fqdn
	}

	if $agentenvironment != '' {
		$cond_environment = $agentenvironment
	} else {
		$cond_environment = $environment
	}

	if $::masterfqdn != '' {

		if $::osfamily == 'Darwin' {

			package { 'mac_puppet':
				ensure   => installed,
				provider => pkgdmg,
				source   => 'http://downloads.puppetlabs.com/mac/facter-2.4.1.dmg',
			}

			package { 'mac_facter':
				ensure   => installed,
				provider => pkgdmg,
				source   => 'http://downloads.puppetlabs.com/mac/puppet-3.7.4.dmg',
			}

		}

		exec { "storing master config":
			command => "echo '${::masterfqdn}' > /etc/puppet/master_conf",
			unless  => "test -e /etc/puppet/master_conf",
		}

		if $::osfamily == 'Debian' {

			class { 'puppet':
				environment => $cond_environment,
				report      => true,
				pluginsync  => true,
				agent       => 'running',
				server      => $::masterfqdn,
				before      => Exec['storing master config']
			}

			concat::fragment{'puppet_conf_agent_splay':
				target  => 'puppet_conf',
				content => "  splay = true\n",
				order   => '21',
			}

			concat::fragment{'puppet_conf_agent_certname':
				target  => 'puppet_conf',
				content => "  certname = ${cond_agentfqdn}\n",
				order   => '22',
			}

		}

	}

}
