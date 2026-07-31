class PagesController < ApplicationController
  def dashboard; end

  def character_data; end

  def spa
    render html: "", layout: true
  end
end
