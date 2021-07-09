require 'rubygems'
require 'roo'
require 'roo-xls'

require './data_downloader'
include DataDownloader

PRICE_DELTA = 0.2
NAME_COLUMN = 1
PRICE_COLUMN = 7
START_ROW = 9

def load_files
  goods = {}

  # populate hash with data from files
  files = DataDownloader.filenames
  files.each do |file|
    print('.')
    spreadsheet = Roo::Spreadsheet.open(file, extension: File.extname(file))

    # getting year and month
    regex_result = file.scan(/([0-9]{4})_([0-9]{2})/) # 2018_02
    if regex_result.none?
      print("Invalid filename #{file}")
      next
    end
    year = regex_result[0][0].to_i
    month = regex_result[0][1].to_i

    # parsing data
    goods_file = {}
    (START_ROW..spreadsheet.last_row).each do |row|
      # get name
      name = spreadsheet.cell(row, NAME_COLUMN).to_s.downcase.strip.gsub(/\s.+/, '')

      # get price, if file <2017, then perform conversion from BYR to BYN
      price = spreadsheet.cell(row, PRICE_COLUMN).to_f
      price /= 10_000 if year < 2017

      goods_file[name] = price
    end

    goods["#{year}.#{month}"] = goods_file
  end

  goods
end

def search(goods, item_name)
  item_name_cap = item_name.downcase

  prices_found = {}

  goods = Hash[goods.sort_by { |key, _val| key }]
  goods.each do |k, v|
    prices_found[k] = v[item_name_cap] if v.key?(item_name_cap)
  end

  # level 1
  # find if it exists
  if prices_found.none?
    print "'#{item_name}' can not be found in database.\n"
    return
  end

  current_price = prices_found.to_a.last[1]
  print "'#{item_name}' is #{current_price} BYN in Minsk these days.\n"

  # level 2
  # get min/max prices
  min = prices_found.min_by { |_k, v| v }
  max = prices_found.max_by { |_k, v| v }
  print "Lowest was on #{min[0]} at price #{min[1]} BYN\n"
  print "Maximum was on #{max[0]} at price #{max[1]} BYN\n"

  # level 3
  # get products with similar price
  similar_goods = []
  goods.to_a.last[1].each do |k, v|
    next if k == item_name_cap
    similar_goods.push(k) if (current_price - v).abs < PRICE_DELTA
  end

  return if similar_goods.none?
  print "For similar price you also can afford:\n"
  similar_goods.each do |name|
    print " * '#{name}'\n"
  end
end

print "Downloading files. Please wait\n"
download_data

print "\nParsing files. Please wait\n"
goods = load_files

print "\nReady. Print 'quit' to exit"
loop do
  print "\n\nWhat price are you looking for?\n"
  print '> '

  item_name = gets.chomp
  exit if item_name == 'quit'

  search(goods, item_name)
end
