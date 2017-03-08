Gem::Specification.new do |s|
  s.name          = 'logstash-filter-zabbix'
  s.version       = '0.1.2'
  s.licenses      = ['Apache-2.0']
  s.summary       = %q{logstash-filter-zabbix - A filter to retain zabbix metrics you want to}
  s.description   = %q{This plugin will keep the specific items you want from zabbix history data stream}
  s.homepage      = 'http://github.com/hupuinc/logstash-filter-zabbix'
  s.authors       = ['Hupu Devops']
  s.email         = 'devops@hupu.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'filter' }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency 'zabbixapi', '2.4.9'
  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'webmock', '1.21.0'
end
