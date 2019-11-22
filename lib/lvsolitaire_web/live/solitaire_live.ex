defmodule LVSolitaireWeb.LVSolitaireLive do
  use Phoenix.LiveView
  alias Solitaire.Game, as: Game
  alias Solitaire.Foundation, as: Foundation
  alias Solitaire.Tableau, as: Tableau
  alias Solitaire.Stock, as: Stock
  alias Solitaire.Deck, as: Deck
  alias Solitaire.Cards, as: Cards
  require Logger

  def mount(_session, socket) do
    {deck,_, _} = Deck.new
           |> Deck.shuffle(Enum.random(0..1))
           |> Game.new
    socket = assign(socket, :game, deck)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""

    <div class="playingCards pile">
      <ul class="pile">
        <%= for card  <- elem(@game,0) do %>
        <li>
          <div class="card rank-<%= elem(card, 1) %> <%= elem(card, 0)%>">
          <span class="rank"><%= elem(card,1) %></span>
          <span class="suit">&<%= elem(card,0) %>;</span>
          </div>
        </li>
      <% end %>
        <li>
          <div class="card little joker"><span class="rank">-</span><span class="suit">Joker</span></div>
        </li>
        <li>
          <div class="card back">*</div>
        </li>
      </ul>
    </div>
    <div class="playingCards pile">
      <ul class="pile">
        <%= for card  <- elem(@game,0) do %>
        <li>
          <div class="card rank-<%= elem(card, 1) %> <%= elem(card, 0)%>">
          <span class="rank"><%= elem(card,1) %></span>
          <span class="suit">&<%= elem(card,0) %>;</span>
          </div>
        </li>
      <% end %>
        <li>
          <div class="card little joker"><span class="rank">-</span><span class="suit">Joker</span></div>
        </li>
        <li>
          <div class="card back">*</div>
        </li>
      </ul>
    </div>
    """
  end

  def handle_event("increment", _, socket) do
    #socket = assign(socket, :counter, socket.assigns.counter + 1)
    socket = update(socket, :counter, &(&1 + 1))

    {:noreply, socket}
  end
end
