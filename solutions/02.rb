class Todo
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags = nil)
    @status = status.downcase.to_sym
    @description = description
    @priority = priority.downcase.to_sym
    @tags = tags ? tags.split(',').map(&:strip): []
  end
end

class Criteria < Proc
  def self.status(status)
    Criteria.new { |task| task.status.eql? status }
  end

  def self.priority(priority)
    Criteria.new { |task| task.priority.eql? priority }
  end

  def self.tags(tags)
    Criteria.new { |task| tags & task.tags == tags }
  end

  def &(other)
    Criteria.new { |task| call(task) and other.call(task) }
  end

  def |(other)
    Criteria.new { |task| call(task) or other.call(task) }
  end

  def !
    Criteria.new { |task| not call(task) }
  end
end

class TodoList
  include Enumerable

  def self.parse(text)
    tasks = text.split("\n").map do |line|
      Todo.new(*line.split('|').map(&:strip))
    end
    TodoList.new(tasks)
  end

  def initialize(tasks)
    @tasks = tasks
  end

  def each(&block)
    @tasks.each(&block)
  end

  def filter(criteria)
    TodoList.new(select(&criteria))
  end

  def adjoin(other)
    TodoList.new(to_a | other.to_a)
  end

  def tasks_todo
    filter(Criteria.status(:todo)).count
  end

  def tasks_in_progress
    filter(Criteria.status(:current)).count
  end

  def tasks_completed
    filter(Criteria.status(:done)).count
  end

  def completed?
   all? { |task| task.status == :done }
  end
end
