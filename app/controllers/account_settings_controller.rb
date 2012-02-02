class AccountSettingsController < InheritedResources::Base

protected
    def begin_of_association_chain
      current_account
    end

end
