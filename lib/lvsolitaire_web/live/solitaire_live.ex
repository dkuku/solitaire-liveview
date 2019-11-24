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
    {reserve,tableau,foundation } = Deck.new
           |> Deck.shuffle(Enum.random(0..1))
           |> Game.new
    socket = assign(socket, :reserve, reserve)
    socket = assign(socket, :tableau, tableau)
    socket = assign(socket, :foundation, foundation)
    {:ok, socket}
  end

  #{
#  {[stos-ukryte],[stos-widoczne]},
#  [
#    {[ukryte],[widoczne]},
#    ...
#  ],
#  [[wiadoczne], [ wodoczne ]]
#
#}
  
  def render(assigns) do
    {invisible,visible} = assigns.reserve
    ~L"""
    <center>
      <div class="playingCards inline">
        <ul class="deck inline">
          <%= for {suit, rank}  <- invisible do %>
            <li>
            <div class="card back">*</div>
            </li>
          <% end %>
          <%= for {suit, rank}  <- visible do %>
            <li>
              <div class="card rank-<%= rank %> <%= suit %>">
                <span class="rank"><%= rank %></span>
                <span class="suit">&<%= suit %>;</span>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
      <%= for color  <- assigns.foundation do %>
        <div class="playingCards inline">
          <ul class="deck inline">
            <li>
              <div class="card"></div>
            </li>
          <%= for {suit, rank}  <- color do %>
            <li>
              <div class="card rank-<%= rank %> <%= suit %>">
                <span class="rank"><%= rank %></span>
                <span class="suit">&<%= suit %>;</span>
              </div>
            </li>
          <% end %>
          </ul>
        </div>
      <% end %>
    </center>
    <center>
      <%= for {invisible, visible}  <- assigns.tableau do %>
        <div class="playingCards inline">
          <ul class="tableau">
            <%= for {suit, rank}  <- invisible do %>
              <li>
                <div class="card back">*</div>
              </li>
            <% end %>
            <%= for {suit, rank}  <- visible do %>
              <li>
                <div class="card rank-<%= rank %> <%= suit %>">
                  <span class="rank"><%= rank %></span>
                  <span class="suit">&<%= suit %>;</span>
                </div>
              </li>
            <% end %>
          </ul>
        </div>
      <% end %>
    </center>
    """
  end

  def handle_event("increment", _, socket) do
    #socket = assign(socket, :counter, socket.assigns.counter + 1)
    socket = update(socket, :counter, &(&1 + 1))

    {:noreply, socket}
  end
end


  #def card(card) do
  #{suit, rank} = {:diams, 1}
  #~L"""
  #<li>
  #  <div class="card rank-<%= rank %> <%= suit %>">
  #    <span class="rank"><%= rank %></span>
  #    <span class="suit">&<%= suit %>;</span>
  #  </div>
  #</li>
  #"""
  #end
