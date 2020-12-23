class VNS
  require 'pry'
  require 'active_support/all'
  attr_reader :people, :sessions, :preferences

  def initialize(people, sessions, preferences)
    @people = people
    @sessions = sessions
    @preferences = preferences
  end

  def run
    initial_groups = people.in_groups(sessions.count).map(&:compact)
    initial_solution = sessions.zip(initial_groups).to_h
    @solution = optimize(initial_solution)

    self
  end

  def print
    puts "Target function: #{target_function(@solution)}\n"
    @solution.each do |session, people|
      puts "#{session.name} => #{people.map(&:name).join(', ')}"
    end

    puts "\nHappiness per person:\n"
    people.each do |person|
      puts "#{person.name} => #{happiness(person)}"
    end

    nil
  end

  private

  def optimize(solution)
    initial_value = target_function(solution)

    combinations = solution.values
                           .combination(2)
                           .map { |(a, b)| a.product(b) }
                           .flatten(1)

    combinations.each do |(p1, p2)|
      swap(solution, p1, p2)
      if target_function(solution) < initial_value
        puts "New enhancement! #{initial_value} => #{target_function(solution)}"
        return optimize(solution)
      else
        swap(solution, p2, p1)
      end
    end

    solution
  end

  def happiness(person)
    preferences[person.id][find_session(@solution, person).id]
  end

  def swap(solution, person1, person2)
    session1 = find_session(solution, person1)
    session2 = find_session(solution, person2)
    solution[session1].delete(person1)
    solution[session2].delete(person2)
    solution[session1] << person2
    solution[session2] << person1
  end

  def find_session(solution, person)
    sessions.detect { |s| solution[s].include?(person) }
  end

  def target_function(solution)
    solution.map do |session, people|
      people.map do |person|
        preferences[person.id][session.id]
      end
    end.flatten.inject(:+)
  end
end
