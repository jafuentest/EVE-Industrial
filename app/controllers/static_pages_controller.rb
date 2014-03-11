class StaticPagesController < ApplicationController
  skip_before_filter :is_admin
  
  def home
  end
end
