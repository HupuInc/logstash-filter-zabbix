# encoding: utf-8

REFRSH_INTERVAL = 6 * 36000 # every 6 hours

class LogStash::Filters::Zabbix::Cache
  require 'zabbixapi'

  attr_accessor :items

  def initialize(logger, options)
    @logger = logger
    @options = options
    @items = {}
  end

  def start
    self.fetch()
    @wt = Thread.new do
      # update zabbix hosts every 6 hours
      while true
        sleep(@options[:interval] || REFRSH_INTERVAL)
        self.fetch()
      end
    end
  end

  def end
    @wt.kill
  end

  def fetch()
    zbx = ZabbixApi.connect(@options)
    response = zbx.query(
      method: 'host.get',
      params: {
          groupids: @options[:group_id],
          output: ['hostid', 'host'],
          selectItems: ['itemid', 'key_', 'formula'],
          selectInterfaces: ['ip'],
      });

    @items = parse(response, @options[:keys])
    @logger.info("Got zabbix items", :size => @items.keys.size)
    @items
  end

  private

  def parse(hosts, keys)
    hosts.reduce({}) do |memo, data|
      data['items'].each do |item|
        if keys.any? { |key| item['key_'].start_with?(key) }
          itemid = item['itemid'].to_i
          memo[itemid] = {
            'id' => data['hostid'],
            'host' => data['host'],
            'ip' => data['interfaces'].first['ip'],
            'name' => item['key_'],
            'formula' => item['formula'].to_i
          }
        end
      end
      memo
    end
  end
end
