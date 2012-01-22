class ColumnPreferencesController < InheritedResources::Base
  actions :edit, :update
  respond_to :html, :json
  respond_to :js, :only => :edit
end
