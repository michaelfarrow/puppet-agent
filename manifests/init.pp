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

	if $::masterfqdn != '' {
		$cond_masterfqdn = $::masterfqdn
	} else {
		$cond_masterfqdn = $::servername
	}

	if $agentenvironment != '' {
		$cond_environment = $agentenvironment
	} else {
		$cond_environment = $environment
	}

	$cond_fqdn_parts = split($cond_agentfqdn, '[.]')
	$cond_hostname = $cond_fqdn_parts[0]

	host { "${hostname}":
		ensure => absent,
		before => Host["${cond_agentfqdn}"],
	}

	host { "${cond_agentfqdn}":
		ensure       => present,
		ip           => '127.0.1.1',
		host_aliases => [ $cond_hostname, 'localhost' ],
	} ->

	exec { "hostname ${cond_hostname}":
		unless       => "hostname | grep -xqe '^${cond_hostname}\$'",
	} ->

	exec { "echo ${cond_hostname} > /etc/hostname":
		unless       => "cat /etc/hostname | grep -xqe '^${cond_hostname}\$'",
	} ->

	class { 'puppet':
		environment => $cond_environment,
		report      => true,
		pluginsync  => true,
		agent       => 'running',
		server      => $cond_masterfqdn
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
