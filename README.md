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
* decimal
* float
* integer
* string
* text
* time

## Timestamps

By default in models with <tt>has_fields</tt> always columns updated_at and created_at created. To ignore 
use <tt>has_fields(:timestamps => false)</tt>

## Status

[<img src="https://secure.travis-ci.org/avakhov/automigration.png"/>](http://travis-ci.org/avakhov/automigration)
