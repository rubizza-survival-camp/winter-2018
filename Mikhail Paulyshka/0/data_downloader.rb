require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'uri'

module DataDownloader
  DIRECTORY = './data/'.freeze
  URL = 'http://www.belstat.gov.by/ofitsialnaya-statistika/makroekonomika-i-okruzhayushchaya-sreda/tseny/operativnaya-informatsiya_4/srednie-tseny-na-potrebitelskie-tovary-i-uslugi-po-respublike-belarus/'.freeze

  def download_file(uri, path)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    File.open(path, 'wb') do |file|
      file.write(URI.parse(uri).open.read)
    end
  end

  def filenames
    Dir.entries(DIRECTORY).reject { |f| File.directory? f }.map { |f| File.join(DIRECTORY, f) }
  end

  def download_data
    page = Nokogiri::HTML(URI.parse(URL).open)

    page.css('a[href*="xls"]').each do |link|
      link = link['href']

      # transform relative links to absolute ones
      link.prepend('http://www.belstat.gov.by') if link.start_with? '/'
      filename = link.split('/').last
      fileext = File.extname(filename)

      # getting file type
      filetype = if (filename.include? 'tov') || (filename.include? 'goods')
                   'goods'
                 elsif filename.include? 'serv'
                   'services'
                 else
                   'unknown'
                 end

      # getting file date
      parsed = false
      regex_result = filename.scan(/([0-9]{2})[-_]([0-9]{4})/) # 08_2019, 08-2018
      if regex_result.any?
        month = regex_result[0][0]
        year = regex_result[0][1]
        parsed = true
      end

      unless parsed
        regex_result = filename.scan(/([0-9]{2})([0-9]{2})/) # 0917
        if regex_result.any?
          month = regex_result[0][0]
          year = '20' + regex_result[0][1]
          parsed = true
        end
      end

      # little hack: file for 12_2014 does not containts year in link
      unless parsed
        if filename.include?('_cpi_12')
          month = '12'
          year = '2014'
          parsed = true
        end
      end

      unless parsed
        puts "Failed to parse filename #{link}"
        next
      end

      filename = "#{year}_#{month}_#{filetype}#{fileext}"

      # perform file loading only if does not exists
      download_path = File.join(DIRECTORY, filename)
      unless File.exist?(download_path)
        print('.')
        download_file(URI.escape(link).gsub('%25', '%'), download_path)
      end
    end
  end
end
