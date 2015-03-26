class agent {

	Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

	exec { "apt-update":
		command => "/usr/bin/apt-get update && touch /tmp/apt-get-updated",
		unless  => "test -e /tmp/apt-get-updated",
	}

	Exec["apt-update"] -> Package <| |>

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

	$cond_fqdn_parts = split($cond_agentfqdn, '[.]')
	$cond_hostname = $cond_fqdn_parts[0]

	stage { 'first':
		before => Stage['main'],
	}

	class { 'agent::hostname_config':
		stage => 'first',
	}

	if $::masterfqdn != '' {

		class { 'puppet':
			environment => $cond_environment,
			report      => true,
			pluginsync  => true,
			agent       => 'running',
			server      => $::masterfqdn
		} ->

		exec { "storing master config":
			command => "echo '${::masterfqdn}' > /etc/puppet/master_conf",
			unless  => "test -e /etc/puppet/master_conf",
		}

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
