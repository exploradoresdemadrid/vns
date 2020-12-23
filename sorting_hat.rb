#!/usr/bin/env ruby

require './session'
require './vns'
require './person'

people = %w[Alice Robert Carl Daniel Evan Fabian Gary Hester Ian James Kyle Lauren Marin Nathalie Orlando Patrick
            Robert Sam Tina Uriah].each_with_index.map do |name, i|
  Person.new i, name
end
sessions = %w[Accounting Butcher Cashier].each_with_index.map { |name, i| Session.new i, name }

OPTIONS = (1..sessions.count).to_a

# preferences = people.map { OPTIONS.shuffle }

preferences = [[3, 1, 2],
               [2, 3, 1],
               [1, 2, 3],
               [1, 2, 3],
               [2, 3, 1],
               [3, 1, 2],
               [2, 3, 1],
               [3, 2, 1],
               [3, 2, 1],
               [2, 1, 3],
               [2, 3, 1],
               [3, 1, 2],
               [3, 2, 1],
               [1, 2, 3],
               [3, 1, 2],
               [2, 3, 1],
               [2, 3, 1],
               [1, 3, 2],
               [3, 2, 1],
               [1, 3, 2]]

puts people.map(&:to_s).join("\n")
puts
puts sessions.map(&:to_s).join("\n")
puts

puts VNS.new(people, sessions, preferences).run.print
