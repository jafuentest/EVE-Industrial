# == Schema Information
#
# Table name: items
#
#  id   :integer          not null, primary key
#  name :string
#
class Item < ApplicationRecord
  self.primary_key = :id

  has_many :orders, dependent: :destroy

  def self.create_items(item_ids)
    item_ids.each do |item_id|
      Item.find_or_create_by!(id: item_id)
    end
  end
end
