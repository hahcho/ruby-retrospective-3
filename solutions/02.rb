class Todo
  include Comparable

  ATTRIBUTES = [:status, :description, :priority, :tags]
  attr_reader *ATTRIBUTES

  def initialize(task_tokens)
    @status = task_tokens[0].downcase.to_sym
    @description = task_tokens[1]
    @priority = task_tokens[2].downcase.to_sym
    @tags = task_tokens[3] ? task_tokens[3].split(',').map(&:strip): []
  end

  def <=>(other)
    compare_result = ATTRIBUTES.map do |attr|
      send(attr) <=> other.send(attr)
    end.find(&:nonzero?)
    compare_result ? compare_result : 0
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
      Todo.new(todo_string.split('|').map(&:strip))
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
