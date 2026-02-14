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
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["SELENIUM_REMOTE_URL"].present?
      driven_by :remote_chrome
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    end
  end

  config.after(:each, type: :system) do
    # Turbo Drive の状態を含むブラウザ状態を完全にリセット
    begin
      page.execute_script('if (typeof Turbo !== "undefined") { Turbo.clearCache(); }')
      page.driver.browser.navigate.to("about:blank")
    rescue Selenium::WebDriver::Error::JavascriptError, Capybara::NotSupportedByDriverError
      # JavaScriptエラーまたはドライバー非対応の場合は無視
    end
    Capybara.reset_sessions!
  end
end

# Turbo Stream のレスポンス待機のため、待機時間を延長
Capybara.default_max_wait_time = 5
