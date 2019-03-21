require 'mechanize'
require 'open-uri'
require 'roo'
require 'addressable/uri'
require 'roo-xls'
require './services'

# Class parses belstat's site and downloads price tables
class DataParser
  extend Services
  URL = 'http://www.belstat.gov.by/ofitsialnaya-statistika/makroekonomika'\
  '-i-okruzhayushchaya-sreda/tseny/operativnaya-informatsiya_4/srednie-tseny'\
  '-na-potrebitelskie-tovary-i-uslugi-po-respublike-belarus/'.freeze
  CSS_SELECTOR = '.table>table>tbody'.freeze

  def self.create_file_by_uri(uri, rename, filename: uri.split('/')[-1],
                              new_path: '.')
    uri = Addressable::URI.escape(uri) unless uri.include?('%')
    IO.copy_stream(URI.open(uri), filename)
    rename_file(filename, new_path) if rename
  end

  def self.rename_file(filename, new_path)
    spreadsheet = open_spreadsheet(filename)
    new_filename = generate_name_for_file(spreadsheet)
    File.rename(filename, new_path + '/' + new_filename +
                File.extname(filename))
  end

  def self.open_spreadsheet(filename)
    Roo::Spreadsheet.open(filename, extension: File.extname(filename))
  end

  def self.generate_name_for_file(spreadsheet)
    parse_year_of_table(spreadsheet) + '.' + parse_month_of_table(spreadsheet)
  end

  def self.create_links_list(table)
    table.search('a').map do |link|
      if link['href'][0] == '/'
        'http://www.belstat.gov.by' + link['href']
      else
        link['href']
      end
    end
  end

  def self.download_data
    agent = Mechanize.new
    Dir.mkdir('data') unless Dir.exist?(Services::PATH_FOR_DATA)
    table = agent.get(URL).search(CSS_SELECTOR).first
    puts 'Creating links list.'
    links = create_links_list(table)
    puts 'Creating and writing files.'
    links.each do |link|
      create_file_by_uri(link, true, new_path: Services::PATH_FOR_DATA)
    end
    puts 'Done.'
  end
end
