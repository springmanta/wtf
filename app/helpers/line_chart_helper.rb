module LineChartHelper
  LINE_CHART_WIDTH = 500
  LINE_CHART_HEIGHT = 160
  LINE_CHART_PADDING = 20

  # [[x, y], ...] plotting `values` (each 0..max) evenly across the chart width.
  def line_chart_coordinates(values, max: 10)
    usable_width = LINE_CHART_WIDTH - (LINE_CHART_PADDING * 2)
    usable_height = LINE_CHART_HEIGHT - (LINE_CHART_PADDING * 2)
    step = values.size > 1 ? usable_width / (values.size - 1).to_f : 0

    values.each_with_index.map do |value, index|
      x = LINE_CHART_PADDING + (step * index)
      y = LINE_CHART_PADDING + usable_height - (usable_height * (value / max.to_f))
      [ x.round(1), y.round(1) ]
    end
  end

  def line_chart_points(values, max: 10)
    line_chart_coordinates(values, max: max).map { |x, y| "#{x},#{y}" }.join(" ")
  end
end
