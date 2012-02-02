class ColumnPreferencesController < InheritedResources::Base

#  protected

    # This is the way to scope everything to the current user in InheritedResources.  This
    # translates into
    # @column_preference = current_user.column_preferences.build(params[:column_preference])
    # in the new/create actions and
    # @column = current_user.column_preferences.find(params[:id]) in the
    # edit/show/destroy actions.
#    def begin_of_association_chain
#      current_user
#    end
end
