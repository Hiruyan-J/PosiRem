if ENV["SELENIUM_REMOTE_URL"].present?
  # リモート Selenium コンテナ用のカスタムドライバーを登録
  Capybara.register_driver :remote_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,1400")

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: ENV["SELENIUM_REMOTE_URL"],
      options: options
    )
  end

  # Selenium コンテナから web コンテナにアクセスできるようにする
  Capybara.server_host = "0.0.0.0"
  Capybara.app_host = "http://web:#{Capybara.server_port}"

  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by :remote_chrome
    end
  end
else
  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    end
  end
end
