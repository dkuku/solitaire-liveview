defmodule LVSolitaireWeb.CardComponent do
  use Phoenix.Component

  attr(:pile, :atom)
  attr(:card, :any)
  attr(:index, :integer, default: 0)

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
      <% {suit, rank} = @card %>
      <div
        phx-click="click"
        phx-value-suit={suit}
        phx-value-rank={rank}
        phx-value-pile={@pile}
        phx-value-index={@index}
        class={["card", focus?(assigns, @card), "rank-#{num_to_rank(rank)}", suit]}
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
         |> Enum.with_index(1)
         |> Map.new(fn {a, b} -> {b, a} end)

  def num_to_rank(rank) do
    @ranks[rank]
  end
end
