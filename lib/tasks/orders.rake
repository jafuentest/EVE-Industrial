namespace :orders do
  desc 'Calls update_character_orders method for every character'
  task import: :environment do
    Character.all.each do |character|
      Order.update_character_orders(character, update_competition: false)
    end
  end
end
