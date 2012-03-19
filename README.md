# ActiveRecord automigrations

[<img src="https://secure.travis-ci.org/boshie/automigration.png"/>](http://travis-ci.org/boshie/automigration)
[<img src="https://gemnasium.com/boshie/automigration.png"/>](http://gemnasium.com/boshie/automigration)


## Overview

``` ruby
class User < ActiveRecord::Base
  # attributes created via migration
  migration_attr :secure_password, :auth_token
  migration_attr :salt

  has_fields do |f|
    f.string :name
    f.integer :login_count
  end
end
```

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

## Timestamps

By default in models with has_fields always columns updated_at and created_at created. To ignore 
use has_fields(:timestamps => false)

## Changelog

### Automigration 0.2.2 (March 19, 2012)

* Remove db:auto rake task, enhance db:migrate instead

### Automigration 0.2.1 (March 18, 2012)

* First public release
