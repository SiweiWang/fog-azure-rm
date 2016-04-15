module Fog
  module Storage
    class AzureRM
      # This class provides the actual implemention for service calls.
      class Real
        def check_storage_account_name_availability(params)
          promise = @storage_mgmt_client.storage_accounts.check_name_availability(params)
          result = promise.value!
          Azure::ARM::Storage::Models::CheckNameAvailabilityResult.serialize_object(result.body)
        end
      end
      # This class provides the mock implementation for unit tests.
      class Mock
        def check_storage_account_name_availability(params)
        end
      end
    end
  end
end
