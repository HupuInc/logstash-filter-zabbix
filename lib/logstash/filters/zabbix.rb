# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::Zabbix < LogStash::Filters::Base
  require "logstash/filters/zabbix/cache"

  config_name "zabbix"

  config :url, :validate => :string, :required => true
  config :user, :validate => :string, :required => true
  config :password, :validate => :string, :required => true
  config :group_id, :validate => :number, :required => true
  config :keys, :validate => :array, :required => true
  config :skip, :validate => :boolean, :default => true

  public
  def register
    options = {
      url: @url,
      user: @user,
      password: @password,
      group_id: @group_id,
      keys: @keys
    }

    @zabbix_updater = Cache.new(@logger, options)
    @zabbix_updater.start
  end # def register

  public
  def filter(event)
    matched = false

    if 'insert' == event.get('type')
      data = event.get("data")
      item = @zabbix_updater.items[data["itemid"]]

      if item
        metric = {
          "host" => item["host"],
          "name" => item["name"],
          "ip" => item["ip"],
          "value" => data["value"].to_f * item["formula"]
        }

        metric.each_pair do |k, v|
          event.set(k, v)
        end

        event.remove("data")
        matched = true
      end
    end

    if not matched and @skip
      return event.cancel
    end

    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Zabbix
