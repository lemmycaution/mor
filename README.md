# Mor

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'mor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mor

## Usage

	require 'mor'
	
	Mor.config do |dalli|
		dalli['servers'] = "localhost:11211"
	end
	
	class Person
		include Mor::Model
		attr_accessor :id, :name
	end
	
	frank = Person.new(id: 1, name: "Frank")
	frank.persisted? # false
	frank.valid? # true
	frank.save # true
	
	Person.find(1) # <Person:0x007fc510892b00 @name="Frank">

## Contributing

1. Fork it ( http://github.com/<my-github-username>/mor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
