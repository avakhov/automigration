# ActiveRecord automigrations

Create/modify/delete Active Record columns without migrations. It works only with PostgreSQL.

## Installation

```
gem 'automigration'
```

## Usage

Add <tt>has_fields</tt> into your models:

``` ruby
class User < ActiveRecord::Base
  has_fields do |f|
    f.string :name
    f.integer :login_count
  end
end
```

Fire in console:

``
rake db:migrate
```

To keep some system tables add to <tt>config/application.rb</tt>

```
  config.automigration.system_tables << %w[hits very_system_table]
```

Supported fields:

* belongs_to
* boolean
* date
* datetime
* float
* integer
* password
* string
* text
* time

## Devise support

ActiveRecord::Base supports all types of devise fields with prefix devise\_

``` ruby
class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :recoverable

  has_fields do |t|
    t.devise_database_authenticatable :null => false
    t.devise_rememberable
    t.devise_trackable
    t.devise_recoverable
  end
end
```

## Globalize2 support

Automigration creates translation tables automatically.

## Timestamps

By default in models with has_fields always columns updated_at and created_at created. To ignore 
use has_fields(:timestamps => false)

## Status

[<img src="https://secure.travis-ci.org/boshie/automigration.png"/>](http://travis-ci.org/boshie/automigration)
[<img src="https://gemnasium.com/boshie/automigration.png"/>](http://gemnasium.com/boshie/automigration)
