# RSpec
gem_group :development, :test do
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails', '~> 4.10.0'
end

gem_group :development do
  gem 'spring-commands-rspec'
end

gem_group :test do
  gem 'launchy', '~> 2.4.3'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
end

after_bundle do
  generate "rspec:install"

  # show visible return from RSpec
  inject_into_file ".rspec", after: "--require spec_helper\n" do
    "--format documentation\n"
  end

  # to use RSpec with generator
  inject_into_file "config/application.rb", after: "config.load_defaults 5.2\n\n" do <<-CODE
    config.generators do |g|
      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
    end
    CODE
  end

  # to use Capybara from RSpec
  inject_into_file "spec/rails_helper.rb", after: "require 'rspec/rails'\n" do
    "require 'capybara/rspec'\n"
  end

  # to use Devise's test helpers
  inject_into_file "spec/rails_helper.rb", after: "# config.filter_gems_from_backtrace(\"gem name\")\n" do <<-CODE

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  CODE
  end 

  # to use support directory
  gsub_file "spec/rails_helper.rb", "# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }", "Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }"
  run "mkdir spec/support"

  # to use shoulda-matchers
  file "spec/support/shoulda_matchers.rb", <<~CODE
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  CODE

  # to use selenium_chrome from capybara
  file "spec/support/capybara.rb", <<~CODE
    Capybara.javascript_driver = :selenium_chrome_headless
  CODE

  # do not use minitest's directory
  run "rm -rf test"
end

# Issue for sqllite3 https://github.com/rails/rails/issues/35153
inject_into_file "Gemfile", after: "gem 'sqlite3'" do
  ", '~> 1.3.6'"
end

# Devise
gem 'devise'

after_bundle do
  generate "devise:install"
  generate "devise User"
  rails_command "db:migrate"
end

# ActiveAdmin
gem 'activeadmin'

after_bundle do
  generate "active_admin:install"
  rails_command "db:migrate"
  rails_command "db:seed"
  generate "active_admin:resource User"
end

# Bootstrap
gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'

after_bundle do
  run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"
  inject_into_file "app/assets/stylesheets/application.scss", after: " */\n" do
    "@import \"bootstrap\";\n"
  end
  inject_into_file "app/assets/javascripts/application.js", after: "//= require_tree .\n" do <<~CODE
    //= require jquery3
    //= require popper
    //= require bootstrap-sprockets
    CODE
  end
end

# Bundle
run "bundle install"
