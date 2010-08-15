class Admin::BaseController < ApplicationController
  filter_access_to :all
  layout 'admin'
end