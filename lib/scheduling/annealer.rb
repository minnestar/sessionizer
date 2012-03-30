module Scheduling
  class Annealer
    def initialize(opts = {})
      @cooling_func = opts[:cooling_func] || lambda do |iter_count|
        Math.exp(iter_count / (opts[:cooling_time] || 1000000))
      end
    
      @transition_probability = opts[:transition_probability] || lambda do |e0, e1, temp|
        Math.exp((e0 - e1) / temp)
      end
    
      @stop_condition = opts[:stop_condition] || lambda do |iter_count, best_energy|
        iter_count > (opts[:max_iter] || 1000)
      end
      
      @repetition_count = opts[:repetition_count] || 1
    end
  
    def anneal(start_state)
      best_state = nil
      best_energy = 1 / 0.0
      energy = start_state.energy
      
      @repetition_count.times do |rep|
        puts "Repetition #{rep}..." if @repetition_count > 1
        state = start_state.dup
        
        iter_count = 0
        while !@stop_condition.call(iter_count, best_energy)
          temperature = @cooling_func.call(iter_count)
          new_state = state.random_neighbor
          new_energy = new_state.energy
          puts "Iteration #{iter_count} (energy = #{new_energy})..." if iter_count % 5000 == 0
      
          if best_state.nil? || @transition_probability.call(energy, new_energy, temperature) > rand
            state, energy = new_state, new_energy
            if new_energy < best_energy
              best_state, best_energy = state, energy
              puts "New best solution on rep #{rep}, iter #{iter_count}:"
              p state
            end
          end
      
          iter_count += 1
        end
      end
      
      best_state
    end
  
  end
end
