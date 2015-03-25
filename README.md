# Puppet Agent Module

```ruby
mod "puppetlabs/stdlib", "4.5.1"
mod "puppetlabs/concat", "1.2.0"
mod "puppetlabs/inifile", "1.2.0"

# dep: puppetlabs/stdlib
# dep: puppetlabs/concat
mod "Aethylred/puppet", "1.5.3"

# dep (optional): puppetlabs/inifile
# dep: Aethylred/puppet
mod "weyforth/agent",
	git: "https://weyforth@bitbucket.org/weyforth/puppet-agent.git",
	ref: "master"
```

