# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/zabbix"
require 'webmock/rspec'

SOURCE = {
  "database" => "zabbix",
  "table" => "proxy_history",
  "type" => "insert",
  "ts" => 1487571666,
  "xid" => 24371619,
  "data" => {
    "id" => 8241572087, "itemid" => 57222689, "clock" => 1487571655,
    "timestamp" => 0, "source" => "", "severity" => 0, "value" => "2.21",
    "logeventid" => 0, "ns" => 783365099, "state" => 0, "lastlogsize" => 0,
    "mtime" => 0, "flags" => 0
  }
}

describe LogStash::Filters::Zabbix do

  describe "Filter all the messages with " do
    let(:config) do <<-CONFIG
      filter {
        zabbix {
          url => "http://localhost/api_jsonrpc.php"
          user => "api"
          password => "api"
          group_id => 65
          keys => ["system.cpu.load"]
        }
      }
    CONFIG
    end

    before(:example) do
      require 'logstash/json'
      # method apiinfo.version
      stub_request(:any, "http://localhost/api_jsonrpc.php")
        .with(
          body: /"method":"apiinfo.version"/,
          headers: {'Accept'=>'*/*', 'Content-Type'=>'application/json-rpc', 'User-Agent'=>'Ruby'}
        )
        .to_return(
          body: JSON.generate({jsonrpc: "2.0", result: "3.2.0"})
        )

      # method user.login
      stub_request(:any, "http://localhost/api_jsonrpc.php")
        .with(
          body: /"method":"user.login"/,
          headers: {'Accept'=>'*/*', 'Content-Type'=>'application/json-rpc', 'User-Agent'=>'Ruby'}
        )
        .to_return(
          body: JSON.generate(
              { jsonrpc: "2.0", result:"randomtoken" }
            )
        )

      # method host.get
      stub_request(:any, "http://localhost/api_jsonrpc.php")
        .with(
          body: /"method":"host.get"/,
          headers: {'Accept'=>'*/*', 'Content-Type'=>'application/json-rpc', 'User-Agent'=>'Ruby'}
        )
        .to_return(
          body: JSON.generate(
            jsonrpc: "2.0",
            result: [{
            hostid: "1036371",
            host: "somehost-ssh-66-66-tst.vm.jh",
            items: [
              {itemid: 57203706, key_: "agent.hostname", formula: 1},
              {itemid: 57203707, key_: "agent.ping", formula: 1},
              {itemid: 57222689, key_: "system.cpu.load[all,avg1]", formula: 1}
            ],
            interfaces: [{ip: "192.168.66.66"}]
          }])
        )
    end

    sample(SOURCE) do
      expect(subject.get('host')).to eq('somehost-ssh-66-66-tst.vm.jh')
    end
  end
end
