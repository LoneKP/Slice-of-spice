class RecipeSource::Sourcer
  require 'nokogiri'
  require 'open-uri'

  def initialize(recipe_source)
    @recipe_source = recipe_source
  end

  def update_recipe_source_with_original_title
    @recipe_source.update(
      original_title: get_original_title,
      image_url: get_original_image
    )
  end

  private

  def get_original_title
    url = @recipe_source.url
    URI.open(url) do |f|
      doc = Nokogiri::HTML(f)
      original_title = doc.at('h1').text
    end
  end

  def get_original_image
    url = @recipe_source.url
    URI.open(url) do |f|
      doc = Nokogiri::HTML(f)

      if doc.css("meta[property='og:image']").present?                                                                                                                                                                                                                                                                    
        img_url = doc.css("meta[property='og:image']").first.attributes["content"].value
      else
        if doc.css("img").first.attributes["src"].value.start_with?("http", "www") 
          img_url = doc.css("img").first.attributes["src"].value
        else
          path = doc.css("img").first.attributes["src"].value
          base = f.base_uri.host
          scheme = f.base_uri.scheme
          origin = scheme + "://" + base
          img_url = URI.join(origin, path).to_s
        end                                                                                                                                                                                                                                    
      end 
    
    end
  end

end