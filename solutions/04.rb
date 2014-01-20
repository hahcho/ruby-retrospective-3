module Asm
  class InstructionExecutorUnit
    conditional_jumps = {
      je:   :==,
      jne:  :!=,
      jl:   :<,
      jle:  :<=,
      jg:   :>,
      jge:  :>=,
    }

    conditional_jumps.each do |instruction_name, operation|
      define_method instruction_name do |argument|
        jmp(argument) if get_value(:compare_flag).send(operation, 0)
      end
    end

    def initialize(execution_unit)
      @execution_unit = execution_unit
    end

    def mov(destination_register, source)
      @execution_unit.registers[destination_register] = get_value(source)
    end

    def inc(destination_register, value)
      mov destination_register, get_value(destination_register) + get_value(value)
    end

    def dec(destination_register, value)
      inc destination_register, -get_value(value)
    end

    def cmp(register, value)
      mov :compare_flag, get_value(register) <=> get_value(value)
    end

    def jmp(label)
      @execution_unit.instruction_pointer = @execution_unit.labels[label]
    end

    private
    def get_value(source)
      if @execution_unit.registers.include? source
        @execution_unit.registers[source]
      else
        source
      end
    end
  end

  class Parser < BasicObject
    def initialize(labels, instruction_pipeline)
      @labels = labels
      @instruction_pipeline = instruction_pipeline
    end

    def label(name)
      @labels[name] = @instruction_pipeline.size
    end

    def method_missing(name, *args)
      if InstructionExecutorUnit.public_method_defined? name
        @instruction_pipeline << [name, *args]
      else
        name
      end
    end
  end

  class ExecutionUnit
    attr_reader :labels, :registers
    attr_accessor :instruction_pointer

    def initialize(&block)
      @labels = {}
      @instruction_pipeline = []
      Parser.new(@labels, @instruction_pipeline).instance_eval &block
      @instruction_executor_unit = InstructionExecutorUnit.new self
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0, compare_flag: 0}
      @instruction_pointer = 0
    end

    def execute_next_instruction
      @instruction_pointer += 1
      instruction = @instruction_pipeline[@instruction_pointer.pred]
      @instruction_executor_unit.public_send *instruction
    end

    def finished?
      @instruction_pipeline.size <= @instruction_pointer
    end

    def execute_program
      until finished?
        execute_next_instruction
      end
    end
  end

  def self.asm(&block)
    control_flow_unit = ExecutionUnit.new &block
    control_flow_unit.execute_program
    [:ax, :bx, :cx, :dx].map do |register_name|
      control_flow_unit.registers[register_name]
    end
  end
end
