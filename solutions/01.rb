class Integer
  def prime?
    return false if self <= 1
    (2...self).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_factors
    number = abs
    if number.prime?
        [number]
    else
      divisor = (2...number).find { |i| number.remainder(i).zero? }
      [divisor] + (number / divisor).prime_factors
    end
  end

  def harmonic
    (1..self).inject(0.to_r) do |harmonic_sum, n|
      harmonic_sum += Rational(1, n)
    end
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    frequinces = Hash.new { |hash, key| hash[key] = 0 }
    each { |n| frequinces[n] += 1 }
    frequinces
  end

  def average
    reduce(0.0, :+) / size
  end

  def drop_every(n)
    filtered_list = []
    each_with_index do |item, index|
      filtered_list << item unless (index + 1).remainder(n).zero?
    end
    filtered_list
  end

  def combine_with(other)
    combined_list = []
    max_index = self.size > other.size ? self.size : other.size

    (0...max_index).each do |n|
      combined_list << self[n] if self[n]
      combined_list << other[n] if other[n]
    end

    combined_list
  end
end
