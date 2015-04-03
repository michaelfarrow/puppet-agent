Facter.add("agentfqdn") do
	setcode do
		Facter::Core::Execution.exec('cat /etc/puppet/agent_conf 2> /dev/null')
	end
end