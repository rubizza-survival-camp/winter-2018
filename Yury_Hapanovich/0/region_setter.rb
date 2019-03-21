# The class helps you to select region.
class RegionSelector
  def initialize(regions)
    @regions = regions
  end

  def select_region
    puts 'Please, select a region: '
    display_regions_list
    input_region
  end

  def display_regions_list
    @regions.each_key do |region|
      puts region.to_s
    end
  end

  def input_region
    until @regions.key?(region = gets.chomp.capitalize)
      puts 'Please, select correct region!'
    end
    region
  end
end
