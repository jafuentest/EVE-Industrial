namespace :export do
  desc 'Export Stars'
  task stars: :environment do
    Star.all.each do |star|
      serialized = star.serializable_hash.symbolize_keys
      puts "Star.create(#{serialized})"
    end
  end
end
