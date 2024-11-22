require 'selenium-webdriver'
require 'logger'

module SteamPriceScraper
  # Initiate Logger
  @@logger = Logger.new('/var/log/steam_price_scrapper.log', datetime_format: '%Y-%m-%d %H:%M:%S')

  # Initiate Webdriver
  # when firefox is installed using snap then you must specify geckodriver path
  @@service = Selenium::WebDriver::Service.firefox
  @@service.executable_path = '/snap/bin/firefox.geckodriver'
  # run browser in headless mode
  @@options = Selenium::WebDriver::Firefox::Options.new(args: ['--headless'])

  # Creating explicit wait object
  @@explicit_wait = Selenium::WebDriver::Wait.new

  def scrape_game(game)
    @@logger.info("Steam Price Scraping Script - Start")
    driver = Selenium::WebDriver.for :firefox, service: @@service, options: @@options
    # Launch firefox
    website = game.game_url
    driver.get website


    # Check if Steam Store page is loaded
    begin
    	@@explicit_wait.until { driver.title.downcase.include?('steam') }
    rescue Selenium::WebDriver::Error::TimeoutError
    	@@logger.fatal("Steam Store page is not loaded. Quitting...")
    	driver.quit
    	exit
    end

    # Check if age verification exists
    begin
    	@@explicit_wait.until { driver.current_url.include?('agecheck') }

    	@@logger.info("Steam Price Scraping Script - Steam agecheck found")
    	@@logger.info("Steam Price Scraping Script - Steam agecheck - start")

    	# Select age
    	day_select = Selenium::WebDriver::Support::Select.new(driver['ageDay'])
    	month_select = Selenium::WebDriver::Support::Select.new(driver['ageMonth'])
    	year_select = Selenium::WebDriver::Support::Select.new(driver['ageYear'])
    	day_select.select_by(:text, '1')
    	month_select.select_by(:text, 'January')
    	year_select.select_by(:text, '2000')

      # Click view page
    	driver['view_product_page_btn'].click()	

    	@@logger.info("Steam Price Scraping Script - Steam agecheck - end")
    rescue Selenium::WebDriver::Error::TimeoutError
    	@@logger.info("Steam Price Scraping Script - Steam agecheck not found. Skipping agecheck")
    end

    # get price
    begin
      # get price element using xpath
    	game_price_xpath = '//div[contains(@class,"game_purchase_price") and @data-price-final]'

    	@@explicit_wait.until { driver.find_element(:xpath, game_price_xpath) }

    	game_price = driver.find_element(:xpath, game_price_xpath)
    	@@logger.info("Steam Price Scraping Script - Game price was found.")
    	@@logger.info("Steam Price Scraping Script - Game title: #{driver.title.gsub('on Steam', '').strip}")
    	@@logger.info("Steam Price Scraping Script - Game price: #{game_price.text}")
      @@logger.info("Steam Price Scraping Script - Saving game price to db - start")
      game_price = GamePrice.new(game_price: game_price.text, game_id: game.id)

      if game_price.save
        @@logger.info("Steam Price Scraping Script - Saving game price to db - success")
      else
        @@logger.info("Steam Price Scraping Script - Saving game price to db - failed")
      end

      @@logger.info("Steam Price Scraping Script - Saving game price to db - end")
    rescue Selenium::WebDriver::Error::TimeoutError
    	@@logger.fatal("Steam Price Scraping Script - Game price was not found. Quitting...")
    end

    # Close browser
    driver.quit
    @@logger.info("Steam Price Scraping Script - End")
  end
end
