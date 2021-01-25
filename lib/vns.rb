module VNS
  require './person'
  require './session'
  require 'active_support/all'

  class VNS
    attr_reader :people, :sessions, :preferences

    PERTURBATION_COUNT = 100

    def initialize(people, sessions, preferences, &inspection)
      @people = people.map.with_index { |person, i| Person.new(i, person) }
      @sessions = sessions.map.with_index { |session, i| Session.new(i, session) }
      @preferences = preferences
      @inspection = inspection
    end

    def run
      initial_groups = people.in_groups(sessions.count).map(&:compact)
      initial_solution = sessions.zip(initial_groups).to_h
      @solution = global_optimize(initial_solution)

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

    def target_function(solution = @solution)
      return Float::INFINITY unless solution

      solution.map do |session, people|
        people.map do |person|
          preferences[person.id][session.id]
        end
      end.flatten.inject(:+)
    end

    private

    def global_optimize(initial_solution)
      best_solution = initial_solution

      first_solution = initial_solution.dup
      local_optimize(first_solution)

      puts "First solution => #{target_function(first_solution)}"
      best_solution = first_solution

      PERTURBATION_COUNT.times do |counter|
        temporary_solution = clone(best_solution)
        perturbate(temporary_solution)
        local_optimize(temporary_solution)

        puts "Perturbation #{counter + 1} => #{target_function(temporary_solution)} vs #{target_function(best_solution)}"

        if target_function(temporary_solution) < target_function(best_solution)
          puts 'Updated best solution'
          best_solution = temporary_solution
        end

        progress = (counter + 1) * 1.0 / PERTURBATION_COUNT
        @inspection.call(progress, target_function(best_solution)) if @inspection
      end

      best_solution
    end

    def clone(solution)
      solution.map do |k, v|
        [k, v.dup]
      end.to_h
    end

    def local_optimize(solution)
      shift_optimization(solution)
      swap_optimization(solution)
    end

    def shift_optimization(solution)
      initial_value = target_function(solution)

      people.product(sessions).each do |(person, session)|
        original_session = find_session(solution, person)
        shift(solution, session, person)

        if feasible?(solution) && target_function(solution) < initial_value
          return local_optimize(solution)
        else
          shift(solution, original_session, person)
        end
      end
    end

    def swap_optimization(solution)
      initial_value = target_function(solution)

      combinations_of_two(solution).each do |(p1, p2)|
        swap(solution, p1, p2)
        if target_function(solution) < initial_value
          return local_optimize(solution)
        else
          swap(solution, p2, p1)
        end
      end
    end

    def perturbate(solution)
      2.times do
        extracted = []
      solution.each do |_, people|
        extracted << people.delete_at(rand(people.length))
      end

      extracted.shuffle.each_with_index do |person, i|
        solution.values[i] << person
      end
      end
    end

    def combinations_of_two(solution)
      solution.values
              .combination(2)
              .map { |(a, b)| a.product(b) }
              .flatten(1)
    end

    def happiness(person)
      preferences[person.id][find_session(@solution, person).id]
    end

    def feasible?(solution)
      solution.values.all? { |group| group.size <= Session::MAX_ALLOCATION }
    end

    def swap(solution, person1, person2)
      session1 = find_session(solution, person1)
      session2 = find_session(solution, person2)
      solution[session1].delete(person1)
      solution[session2].delete(person2)
      solution[session1] << person2
      solution[session2] << person1
    end

    def shift(solution, session, person)
      solution[find_session(solution, person)].delete(person)
      solution[session] << person
    end

    def find_session(solution, person)
      sessions.detect { |s| solution[s].include?(person) }
    end
  end
end