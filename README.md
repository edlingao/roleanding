# README

This is the README for Roleanding Social Network

1. ERD
    ![ERD](https://www.lucidchart.com/publicSegments/view/7a70c68f-9f12-4e03-bdbd-d69c39a9b4bb/image.png)

## Setup instructions 
2. Ruby version
    > 2.5.6
3. Gems used
    * `gem 'devise'`
    * `gem 'paperclip-cloudinary'`
    * `gem "paperclip", "~> 6.0.0"`
    * `gem 'omniauth-facebook'`
    * `gem 'rubocop'`
4. To start
    * ## RUN `bundle`
    * Go to `config > database.yml`
    * Configure the DB on `database.yml`
        *   `default: &default`
        *   `adapter: postgresql`
        *   `encoding: unicode`
        *   `username: [YOUR USERNAME]`
        *   `password: [YOUR PASSWORD]`
        *   `# For details on connection pooling, see Rails configuration guide`
        *   `# http://guides.rubyonrails.org/configuring.html#database-pooling`
        *   `pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>`
        *   `gem 'rspec'`
        *   `gem 'jquery-rails'`
        *   `gem 'database_cleaner'`
    * ## RUN `rails db:create`
    * ## RUN `rails db:migrate`

    ## Live example
    [Roleanding](https://roleanding.herokuapp.com/)
