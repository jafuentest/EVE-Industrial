# == Schema Information
#
# Table name: characters_blueprints
#
#  id                  :integer          not null, primary key
#  character_id        :integer
#  type_id             :integer
#  location_id         :integer
#  location_flag       :string
#  quantity            :integer
#  material_efficiency :integer
#  time_efficiency     :integer
#  runs                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class CharactersBlueprint < ApplicationRecord
end
