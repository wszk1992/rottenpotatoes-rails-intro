class Movie < ActiveRecord::Base
	def self.ratingValues
		['G','PG','PG-13','R']
	end
end
