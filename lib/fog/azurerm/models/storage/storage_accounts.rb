require 'fog/core/collection'
require 'fog/azurerm/models/storage/storage_account'
# rubocop:disable LineLength
# rubocop:disable MethodLength
# rubocop:disable AbcSize
module Fog
  module Storage
    class AzureRM
      # This class is giving implementation of all/list, get and
      # check name availability for storage account.
      class StorageAccounts < Fog::Collection
        model Fog::Storage::AzureRM::StorageAccount
        attribute :resource_group
        def all
          accounts = []
          if !resource_group.nil?
            requires :resource_group
            hash_of_storage_accounts = service.list_storage_account_for_rg(resource_group)
          else
            hash_of_storage_accounts = service.list_storage_accounts
          end
          hash_of_storage_accounts.each do |account|
            hash = {}
            account.instance_variables.each do |var|
              hash[var.to_s.delete('@')] = account.instance_variable_get(var)
            end
            accounts << hash
          end
          load(accounts)
        end

        def get(identity)
          all.find { |f| f.name == identity }
        rescue Fog::Errors::NotFound
          nil
        end

        def check_name_availability(name)
          params = Azure::ARM::Storage::Models::StorageAccountCheckNameAvailabilityParameters.new
          params.name = name
          params.type = 'Microsoft.Storage/storageAccounts'
          Fog::Logger.debug "Checking Name availability: #{name}."
          name_available_obj = service.check_storage_account_name_availability(name)
          if name_available_obj['nameAvailable'] == "true"
          Fog::Logger.debug "Name: #{name} is available."
          else
          Fog::Logger.debug "Name: #{name} is not available."
          end
        end
      end
    end
  end
end
