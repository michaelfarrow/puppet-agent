class agent::hostname_config {

	if $::agentfqdn != '' {
		$cond_agentfqdn = $::agentfqdn
	} else {
		$cond_agentfqdn = $::fqdn
	}

	$cond_fqdn_parts = split($cond_agentfqdn, '[.]')
	$cond_hostname = $cond_fqdn_parts[0]

	host { "${hostname}":
		ensure => absent,
		before => Host["localhost"],
	}

	host { "localhost":
		ensure => present,
		ip     => '127.0.0.1'
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
	}

}