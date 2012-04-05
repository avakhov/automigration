# ActiveRecord automigrations

Create/modify/delete Active Record columns without migrations.
It works with PostgreSQL and SQLite.

## Installation

```
gem 'automigration'
```

## Usage

Add <tt>has_fields</tt> into your models:

``` ruby
class User < ActiveRecord::Base
  has_fields do
    string :name
    integer :login_count
  end
end
```

Fire in console:

```
rake db:migrate
```

To keep some system tables add to <tt>config/application.rb</tt>

```
  config.automigration.system_tables += %w[hits very_system_table]
```

Supported fields:

* belongs_to
* boolean
* date
* datetime
* float
* integer
* string
* text
* time

## Devise support

ActiveRecord::Base supports all types of devise fields with prefix devise\_

``` ruby
class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :recoverable

  has_fields do
    devise_database_authenticatable :null => false
    devise_rememberable
    devise_trackable
    devise_recoverable
  end
end
```

## Timestamps

By default in models with <tt>has_fields</tt> always columns updated_at and created_at created. To ignore 
use <tt>has_fields(:timestamps => false)</tt>

## Status

[<img src="https://secure.travis-ci.org/boshie/automigration.png"/>](http://travis-ci.org/boshie/automigration)
[<img src="https://gemnasium.com/boshie/automigration.png"/>](http://gemnasium.com/boshie/automigration)
