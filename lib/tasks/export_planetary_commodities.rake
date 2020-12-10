namespace :export do
  desc 'Export Planetary Commodities'
  task planetary_commodities: :environment do
    PlanetaryCommodity.all.each do |pc|
      serialized = pc.serializable_hash.symbolize_keys
      puts "PlanetaryCommodity.create(#{serialized})"
    end
  end
end
