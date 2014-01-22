module Asm
  class Parser
    INSTRUCTION_SET = [:mov, :inc, :dec, :inc, :cmp, :jmp,
                    :je, :jne, :jg, :jge, :jl, :jle].freeze

    attr_reader :instructions, :labels

    def initialize
      @labels = Hash.new{ |hash, key| key }
      @instructions = []
    end

    def label(name)
      @labels[name] = instructions.size
    end

    def method_missing(name, *args)
      if INSTRUCTION_SET.include? name
        @instructions << [name, *args]
      else
        name
      end
    end
  end

  class Executor < Struct.new(:cpu, :instructions, :labels)
    JUMPS = {
      je:   :==,
      jne:  :!=,
      jg:   :>,
      jge:  :>=,
      jl:   :<,
      jle:  :<=
    }.freeze

    JUMPS.each do |jump_name, operation|
      define_method jump_name do |label|
        jmp label, (cpu.flag.send operation, 0)
      end
    end

    def mov(destination_register, source)
      cpu[destination_register] = get_value(source)
    end

    def inc(destination_register, value = 1)
      cpu[destination_register] += get_value(value)
    end

    def dec(destination_register, value = 1)
      cpu[destination_register] -= get_value(value)
    end

    def cmp(register, value)
      cpu.flag = cpu[register] <=> get_value(value)
    end

    def jmp(label, condition = true)
      cpu.instruction_pointer = labels[label] if condition
    end

    def execute_next_instruction
      cpu.instruction_pointer += 1
      send *instructions[cpu.instruction_pointer.pred]
    end

    def get_value(source)
        source.is_a?(Symbol) ? cpu[source] : source
    end
  end

  class CPU < Struct.new(:ax, :bx, :cx, :dx, :flag, :instruction_pointer)
    def self.execute(&block)
      parser = Parser.new
      parser.instance_eval &block
      new(*(Array.new(6, 0))).instance_eval do
        executor = Executor.new(self, parser.instructions, parser.labels)
        while parser.instructions.size > instruction_pointer do
          executor.execute_next_instruction
        end
        [ax, bx, cx, dx]
      end
    end
  end

  def self.asm(&block)
    CPU.execute &block
  end
end
