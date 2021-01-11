# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sqlserver'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x/sqlserver/sql_connection'))

Puppet::Type.type(:sqlserver_tsql).provide(:mssql, parent: Puppet::Provider::Sqlserver) do
  desc 'SQLServer TSQL provider'
  def run(query)
    debug("Running resource #{query} against #{resource[:instance]}")
    config = get_config.merge(database: resource[:database])
    sqlconn = PuppetX::Sqlserver::SqlConnection.new

    sqlconn.open_and_run_command(query, config)
  end

  def get_config(instance = resource[:instance])
    config_resc = resource.catalog.resources.find do |resc|
      resc.title =~ %r{Sqlserver::Config} &&
        resc.original_parameters[:instance_name] =~ %r{#{instance}}i
    end
    if config_resc.nil?
      raise("Sqlserver_tsql[#{resource.title}] was unable to retrieve the config, please ensure the catalog contains sqlserver::config{'#{resource[:instance]}':}")
    end

    config_resc.original_parameters
  end
end
