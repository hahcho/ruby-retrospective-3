class Integer
  def prime?
    self >= 2 and 2.upto(pred).all? { |n| remainder(n).nonzero? }
  end

  def prime_factors
    primes = 2.upto(abs).select(&:prime?)
    primes.map do |prime|
      [prime] * abs.downto(0).min_by { |power| abs % prime ** power }
    end.flatten
  end

  def harmonic
    1.upto(self).map { |n| 1 / n.to_r }.reduce(:+)
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    each_with_object(Hash.new(0)) { |element, hash| hash[element] += 1 }
  end

  def average
    reduce(0.0, :+) / size
  end

  def drop_every(n)
    select.with_index { |_, index| index.succ.remainder(n).nonzero? }
  end

  def combine_with(other)
    if empty? or other.empty?
      self | other
    else
      take(1) + other.take(1) + drop(1).combine_with(other.drop 1)
    end
  end
end
