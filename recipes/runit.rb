# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: runit
#
# Copyright 2014, Rackspace Hosting
#

include_recipe 'runit::default'

node['nodestack']['apps'].each do |app| # each app loop

  app_name = app[0]
  app_config = node['nodestack']['apps'][app_name]
  unless app_config['services'] || !app_config['services'].empty?
    node.default['nodestack']['apps'][app_name]['services'][app_name]
  end

  services = node['nodestack']['apps'][app_name]['services']

  # Setup Services
  services.each do |service| # each service loop
    service_name = service.is_a?(Array) ? service[0] : service
    node.set_unless['nodestack']['apps'][app_name]['services'][service_name]['runit'] = {}
    service_config = node['nodestack']['apps'][app_name]['services'][service_name]

    sv_dir = service_config['runit']['sv_dir'] ? service_config['runit']['sv_dir'] : '/etc/sv'
    cookbook = service_config['runit']['cookbook'] ? service_config['runit']['cookbook'] : 'nodestack'
    env = if service_config['env']
            service_config['env']
          elsif app_config['env']
            app_config['env']
          else
            {}
          end
    options = service_config['options'] || {
      cookbook_name: cookbook,
      app_dir: app_config['app_dir'],
      env_dir: env.empty? ? nil : "#{sv_dir}/#{app_name}/env",
      app_user: app_config['app_user'],
      binary_path: node['nodestack']['binary_path'],
      entry: app_config['entry_point'] || 'server.js'
    }

    runit_service service_name do
      sv_dir sv_dir
      sv_templates service_config['runit']['sv_templates']
      cookbook cookbook
      run_template_name service_config['runit']['run_template_name'] || 'default'
      log_template_name service_config['runit']['log_template_name']
      options options
      env env
      log service_config['runit']['log'] || true
      default_logger service_config['runit']['default_logger'] || true
      owner service_config['runit']['owner'] || app_config['app_user']
      group service_config['runit']['group'] || app_config['app_user']
      restart_on_update service_config['runit']['restart_on_update'] || false
    end
  end

end
