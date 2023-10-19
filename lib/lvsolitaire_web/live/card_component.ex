defmodule LVSolitaireWeb.CardComponent do
  use Phoenix.Component

  attr(:pile, :atom)
  attr(:card, :any)
  attr(:index, :integer)

  def card(%{card: :placeholder} = assigns) do
    ~H"""
    <li>
      <div phx-click="click-empty" phx-value-pile={@pile} phx-value-index={@index} class="placeholder">
      </div>
    </li>
    """
  end

  def card(%{pile: :deck, card: :back} = assigns) do
    ~H"""
    <li>
      <div phx-click="click-deck" class="card back">*</div>
    </li>
    """
  end

  def card(%{pile: :tableau, card: :back} = assigns) do
    ~H"""
    <li>
      <div class="card back">*</div>
    </li>
    """
  end

  def card(%{card: {_, _}} = assigns) do
    ~H"""
    <li>
      <div
        phx-click="click"
        phx-value-suit={elem(@card, 0)}
        phx-value-rank={elem(@card, 1)}
        phx-value-pile={@pile}
        phx-value-index={@index}
        class={["card", focus?(assigns, @card), "rank-#{num_to_rank(elem(@card, 1))}", elem(@card, 0)]}
      >
        <span class="rank"><%= num_to_rank(elem(@card, 1)) %></span>
        <span class="suit">&<%= elem(@card, 0) %>;</span>
      </div>
    </li>
    """
  end

  def card(assigns) do
    ~H"""
    <li>
      <div phx-click="moves" class="card"></div>
    </li>
    """
  end

  def focus?(%{clicked: clicked}, clicked), do: "focus"
  def focus?(%{clicked: _}, _), do: ""
  def focus?(%{}, _), do: ""

  @ranks [:a, 2, 3, 4, 5, 6, 7, 8, 9, 10, :j, :q, :k]

  def num_to_rank(rank), do: Enum.at(@ranks, rank - 1)
end
