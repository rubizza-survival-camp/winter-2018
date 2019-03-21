# The module store some common functions and constants
module Services
  PATH_FOR_DATA = './data'.freeze
  FIRST_PRODUCT_ROW = 9
  DENOMINATION_RATE = 0.0001
  DENOMINATION_YEAR = 2017

  def self.user_input_check
    %w[y Y д Д].include?(gets.chomp)
  end

  def parse_year_of_table(spreadsheet)
    spreadsheet.cell(3, 'A').split(' ')[-2]
  end

  def parse_month_of_table(spreadsheet)
    months = { 'январь' => 1, 'февраль' => 2, 'март' => 3,
               'апрель' => 4, 'май' => 5, 'июнь' => 6, 'июль' => 7,
               'август' => 8, 'сентябрь' => 9, 'октябрь' => 10,
               'ноябрь' => 11, 'декабрь' => 12 }
    months[spreadsheet.cell(3, 'A').split(' ')[-3]].to_s
  end

  def parse_product_name(table, row)
    table.cell(row, 'A').to_s
  end
end
