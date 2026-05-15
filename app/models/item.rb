# == Schema Information
#
# Table name: items
#
#  id   :integer          not null, primary key
#  name :string
#
class Item < ApplicationRecord
  self.primary_key = :id

  has_many :industry_jobs, dependent: :destroy
  has_many :orders, dependent: :destroy

  before_save :set_name

  def self.create_items(item_ids)
    item_ids.each do |item_id|
      Item.find_or_create_by!(id: item_id)
    end
  end

  private

  def set_name
    self.name = ESI.fetch_item_name(id)
  end
end
