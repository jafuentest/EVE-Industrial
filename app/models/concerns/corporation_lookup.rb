module CorporationLookup
  extend ActiveSupport::Concern

  CACHE_TTL = 12.hours

  def corporation_name
    return "" if character_id.blank?

    cached_corporation_name.to_s
  rescue StandardError => e
    Rails.logger.warn("ESI corporation lookup failed for character #{character_id}: #{e.message}")
    ""
  end

  def refresh_corporation_name
    Rails.cache.delete(corporation_name_cache_key)
    corporation_name
  end

  private

  # Yields nil when ESI can't resolve a name, so skip_nil keeps the miss out of the cache
  def cached_corporation_name
    Rails.cache.fetch(corporation_name_cache_key, expires_in: CACHE_TTL, skip_nil: true) do
      corporation_id = ESI.fetch_character_details(character_id)["corporation_id"]
      ESI.fetch_corporation_details(corporation_id)["name"] if corporation_id.present?
    end
  end

  def corporation_name_cache_key
    "corporation_name/#{character_id}"
  end
end
