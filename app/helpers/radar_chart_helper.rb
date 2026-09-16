module RadarChartHelper
  RADAR_SIZE = 300
  RADAR_CENTER = RADAR_SIZE / 2.0
  RADAR_RADIUS = 100
  RADAR_MAX = 10

  # One "x,y" pair for the given axis index (0-based, out of `count` axes)
  # and value (0..RADAR_MAX), measured from straight up, clockwise.
  def radar_point(index, count, value, radius: RADAR_RADIUS)
    angle = (-90 + (index * (360.0 / count))) * Math::PI / 180
    distance = radius * (value / RADAR_MAX.to_f)
    x = RADAR_CENTER + distance * Math.cos(angle)
    y = RADAR_CENTER + distance * Math.sin(angle)
    "#{x.round(1)},#{y.round(1)}"
  end

  # "x1,y1 x2,y2 ..." for a polygon tracing the given ordered values.
  def radar_polygon_points(values, radius: RADAR_RADIUS)
    values.each_with_index.map { |value, index| radar_point(index, values.size, value, radius: radius) }.join(" ")
  end
end
