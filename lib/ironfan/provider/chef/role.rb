module Ironfan
  class Provider
    class ChefServer

      class Role < Ironfan::Provider::Resource
        delegate :active_run_list_for, :add_to_index, :cdb_destroy, :cdb_save,
          :chef_server_rest, :class_from_file, :couchdb, :couchdb=,
          :couchdb_id, :couchdb_id=, :couchdb_rev, :couchdb_rev=, :create,
          :default_attributes, :delete_from_index, :description, :destroy,
          :env_run_list, :env_run_lists, :environment, :environments,
          :from_file, :index_id, :index_id=, :index_object_type, :name,
          :override_attributes, :recipes, :run_list, :run_list_for, :save,
          :set_or_return, :to_hash, :update_from!, :validate,
          :with_indexer_metadata,
        :to => :adaptee

        def initialize(config)
          super
          if self.adaptee.nil? and not config[:expected].nil?
            expected = config[:expected]
            desc = "Ironfan generated role for #{expected.name}"
            self.adaptee = Chef::Role.new
            self.name                   expected.name
            self.override_attributes    expected.override_attributes
            self.default_attributes     expected.default_attributes
            self.description            desc
          end
          raise "Missing adaptee" if self.adaptee.nil?
          self
        end

        #
        # Manipulation
        #
        def self.save!(computer)
          dsl_roles = []
          dsl_roles << computer.server.cluster_role
          dsl_roles << computer.server.facet_role

          dsl_roles.each do |dsl_role|
            next if recall? dsl_role.name       # Handle each role only once
            role = remember new(:expected => dsl_role)
            role.save
          end
        end
      end

    end
  end
end
