source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

group :development, :test do
  gem "pry", "~> 0.12"
  gem "pry-byebug", "~> 3.6"
  gem "pry-doc"
end

group :test do
  gem "rspec", "~> 3.0"
  gem 'coveralls', require: false
end

group :development do
  gem "bundler", "~> 1.17"
  gem "rake", "~> 10.0"
end
