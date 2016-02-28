class Movie < ActiveRecord::Base
  def all_ratings
    ["G", "PG", "PG-13", "R", "NC-17"]
  end
end
