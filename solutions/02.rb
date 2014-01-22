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
    Criteria.new { |arg| arg.status.eql? status }
  end

  def self.priority(priority)
    Criteria.new { |arg| arg.priority.eql? priority }
  end

  def self.tags(tags)
    Criteria.new { |arg| tags & arg.tags == tags }
  end

  def &(other)
    Criteria.new { |arg| call(arg) and other.call(arg) }
  end

  def |(other)
    Criteria.new { |arg| call(arg) or other.call(arg) }
  end

  def !
    Criteria.new { |arg| not call(arg) }
  end
end

class TodoList
  include Enumerable

  def self.parse(todos_string)
    todos = todos_string.split("\n").map do |todo_string|
      Todo.new(*todo_string.split('|').map(&:strip))
    end
    TodoList.new(todos)
  end

  def initialize(todos)
    @todos = todos
  end

  def each(&block)
    @todos.each(&block)
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
