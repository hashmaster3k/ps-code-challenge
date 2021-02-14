module Statistical
  def percentile(values, percentile)
    sorted = values.sort

    x = (percentile * (sorted.length - 1) + 1).floor - 1
    y = (percentile * (sorted.length - 1) + 1).modulo(1)

    sorted[x] + (y * (sorted[x + 1] - sorted[x]))
  end
end
