module PlayersHelper
  def sortable_column_link(column, label)
    is_current = @sort == column
    next_direction = is_current && @direction == "asc" ? "desc" : "asc"

    text = label
    text += is_current ? (@direction == "asc" ? " ▲" : " ▼") : ""

    link_to text, players_path(sort: column, direction: next_direction), class: "hover:underline"
  end
end
