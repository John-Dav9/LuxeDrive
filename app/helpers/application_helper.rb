module ApplicationHelper
  def flag_emoji(country_code)
    return "" if country_code.blank?

    country_code.upcase.each_char.map { |c| (0x1F1E6 + c.ord - 65).chr(Encoding::UTF_8) }.join
  rescue StandardError
    ""
  end
end
