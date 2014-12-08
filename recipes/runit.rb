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
  services = app_config['services'] || [app_name]

  # Setup Services
  services.each do |service| # each service loop
    service_name = service.is_a?(Array) ? service[0] : service
    if node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name)
      service_config = node['nodestack']['apps'][app_name]['services'][service_name]
    else
      service_config = {}
    end

    sv_dir = node.deep_fetch('nodestack', 'apps', app_name, 'runit', 'sv_dir') ? service_config['runit']['sv_dir'] : '/etc/sv'
    cookbook = node.deep_fetch('nodestack', 'apps', app_name, 'runit', 'cookbook') ? service_config['runit']['cookbook'] : 'nodestack'
    env = node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'env') ? service_config['env'] : app_config['env']
    options = node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'options') || {
      cookbook_name: cookbook,
      app_dir: app_config['app_dir'],
      env_dir: env.empty? ? nil : "#{sv_dir}/#{app_name}/env",
      app_user: app_config['app_user'],
      binary_path: node['nodestack']['binary_path'],
      entry: app_config['entry_point'] || 'server.js'
    }

    runit_service service_name do
      sv_dir sv_dir
      sv_templates node.deep_fetch('nodestack', 'apps', app_name, 'runit', 'sv_templates') ? service_config['runit']['sv_templates'] : true
      cookbook cookbook
      run_template_name node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'run_template_name') ? service_config['run_template_name'] : 'default'
      log_template_name node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'log_template_name') ? service_config['log_template_name'] : 'default'
      options options
      env env
      log node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'log') || true
      default_logger node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'default_logger') || true
      owner node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'owner') ? service_config['owner'] : app_config['app_user']
      group node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'group') ? service_config['group'] : app_config['app_user']
      restart_on_update node.deep_fetch('nodestack', 'apps', app_name, 'services', service_name, 'restart_on_update') || false
    end
  end

end
