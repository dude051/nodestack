# Encoding: utf-8

require_relative 'spec_helper'

# If you run this spec solo it will fail due
# to the inclusion of nodestack::postgresql_base
describe 'nodestack::postgresql_slave' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        recipes = %w(
          nodestack::postgresql_base
          pg-multi::pg_slave
        )
        it 'includes recipes' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end
      end
    end
  end
end
