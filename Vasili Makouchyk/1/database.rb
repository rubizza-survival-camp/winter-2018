require 'nokogiri'
require 'mechanize'
require 'redis'
require 'open-uri'

URL = 'http://rapstyle.su/quotes.php'.freeze

class DataBase
  def initialize
    @database = Redis.new
    @quotes = []
    # download_page
    scrape_quotes
    set_db
  end

  def download_page
    agent = Mechanize.new
    page = agent.get(URL)
    File.write('citaty.html', page.body)
  end

  def scrape_quotes
    page = Nokogiri::HTML(open(URL)) # File.read('citaty.html'))
    @quotes = page.css('.post-entry p')
  end

  def set_db
    abort("Quotes hadn't been scraped") if @quotes.empty?
    @quotes.each_with_index do |quote, index|
      @database.set(index, quote.inner_text)
    end
  end

  def random_quote
    @database.get(@database.randomkey)
  end
end
