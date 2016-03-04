require 'set'

class Task
  attr_reader :name, :task, :status, :deps

  def initialize(name, &task)
    @name = name
    @task = task
    @status = :unborn
    @deps = Set.new
    @mutex = Mutex.new
  end

  def add_dependency(tasks)
    tasks.each do |t|
      raise "#{t} should be an object of class Task" unless t.is_a? Task
      @deps.add t
    end
  end

  def do_it
    @mutex.synchronize do
      unless @status == :unborn
        return
      end
      @status = :pending

      if @deps.empty?
        @status = :done
      else
        tasks = []
        @deps.each do |t|
          tasks << Thread.new { t.do_it }
        end
        tasks.each { |t| t.join }
      end
      @status = :running
      @task.call
      @status = :done
    end
  end
end

t1 = Task.new "t1", &lambda { puts "t1" }
t2 = Task.new "t2", &lambda { puts "t2" }
t3 = Task.new "t3", &lambda { puts "t3" }
t4 = Task.new "t4", &lambda { puts "t4" }
t5 = Task.new "t5", &lambda { puts "t5" }
t6 = Task.new "t6", &lambda { puts "t6" }
t7 = Task.new "t7", &lambda { puts "t7" }
t1.add_dependency [t2, t3]
t2.add_dependency [t4]
t3.add_dependency [t4, t6, t7]
t4.add_dependency [t5, t6]
t1.do_it
