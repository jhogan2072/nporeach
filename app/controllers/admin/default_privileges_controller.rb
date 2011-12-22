class Admin::DefaultPrivilegesController < ApplicationController
  include Saas::ControllerHelpers

  def update
    @default_privilege = DefaultPrivilege.find(params[:id])
    @default_privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @default_privilege.operations += value.to_i
    end
    update!
  end

  def create
    @default_privilege = DefaultPrivilege.new(params[:default_privilege])
    @default_privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @default_privilege.operations += value.to_i
    end
    create!
  end
end
