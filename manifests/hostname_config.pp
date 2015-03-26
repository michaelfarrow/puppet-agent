class agent::hostname_config {

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
	}

}