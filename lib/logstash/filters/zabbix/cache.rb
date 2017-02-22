# encoding: utf-8
class LogStash::Filters::Zabbix::Cache
  require 'zabbixapi'

  def self.fetch(options)
    zbx = ZabbixApi.connect(options)
    response = zbx.query(
      method: 'host.get',
      params: {
          groupids: options[:group_id],
          output: ['hostid', 'host'],
          selectItems: ['itemid', 'key_', 'formula'],
          selectInterfaces: ['ip'],
      });

    return parse(response, options[:keys])
  end

  private

  def self.parse(hosts, keys)
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
