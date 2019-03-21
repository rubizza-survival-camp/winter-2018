require './get_data'
require './price_searcher'
require './services'

until Dir.exist?(Services::PATH_FOR_DATA) &&
      !Dir[Services::PATH_FOR_DATA + '/*'].empty?
  puts 'You need to download data files'
  puts 'Do you want to download them? (y/n)'
  DataParser.download_data if Services.user_input_check
end

answer = true
while answer
  PriceSearcher.new.analyze
  puts 'Do you want to look for something else? (y/n)'
  answer = Services.user_input_check
end
