require 'roo'
require 'roo-xls'
require './services'

# The class is used to search for min and max values.
class MinMaxSearcher
  include Services
  def initialize(products, region, regions)
    @products = products
    @current_region = region
    @regions = regions
  end

  def find_min_max
    Dir[PATH_FOR_DATA + '/*'].each do |file|
      table = Roo::Spreadsheet.open(file, extension: File.extname(file))
      scan_table(file, table)
    end
    @products
  end

  def scan_table(file, table)
    (FIRST_PRODUCT_ROW..table.last_row).each do |row|
      next unless check_product_name(table, row)

      price = fix_denominated_prices(table, row)
      compare_prices(price, parse_product_name(table, row),
                     File.basename(file, '.*'))
    end
  end

  def check_product_name(table, row)
    @products.key?(parse_product_name(table, row))
  end

  def fix_denominated_prices(table, row)
    year = parse_year_of_table(table).to_i
    price = table.cell(row, @regions[@current_region]).to_f
    if year < DENOMINATION_YEAR
      (DENOMINATION_RATE * price).round(2)
    else
      price.round(2)
    end
  end

  def compare_prices(price, product, date)
    if price < @products[product][1] && price != 0
      @products[product][1] = price
      @products[product][2] = date
    elsif price > @products[product][3]
      @products[product][3] = price
      @products[product][4] = date
    end
  end
end
