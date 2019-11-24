defmodule LVSolitaireWeb.LVSolitaireLive do
  use Phoenix.LiveView
  alias Solitaire.Game, as: Game
  alias Solitaire.Foundation, as: Foundation
  alias Solitaire.Tableau, as: Tableau
  alias Solitaire.Stock, as: Stock
  alias Solitaire.Deck, as: Deck
  alias Solitaire.Cards, as: Cards
  require Logger

  @ranks [:a,2,3,4,5,6,7,8,9,10,:j,:q,:k]
  def num_to_rank(rank), do: Enum.at(@ranks, rank - 1)
  def mount(_session, socket) do
    game = Deck.new
           |> Deck.shuffle(Enum.random(0..1))
           |> Game.new
    socket = assign(socket, :game, game)
    socket = assign(socket, :clicked, nil)
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
  def focus?(%{clicked: nil}, _), do: ""
  def focus?(%{clicked: clicked}, card) do
    if clicked == card do
      "focus"
    else
      ""
    end
  end
  def render_card(assigns, pile_type, {suit, rank} = card, index \\ nil) do 
    ~L"""
    <li>
    <div phx-click="click"
    phx-value-suit="<%= "#{suit}" %>"
    phx-value-rank="<%= "#{rank}" %>"
    phx-value-pile="<%= "#{pile_type}" %>"
    phx-value-index="<%= "#{index}" %>"
    class="card <%= focus?(assigns, card) %> rank-<%= num_to_rank( rank ) %> <%= suit %>">
        <span class="rank"><%= num_to_rank(rank) %></span>
        <span class="suit">&<%= suit %>;</span>
      </div>
    </li>
    """
  end
  def render_card(assigns, :deck, :back, _) do 
    ~L"""
    <li><div phx-click="click-deck" class="card back">*</div></li>
    """
  end
  def render_card(assigns, :tableau, :back, _) do 
    ~L"""
    <li><div class="card back">*</div></li>
    """
  end
  def render_card(assigns, :foundation, _, index) do 
    ~L"""
    <li><div phx-click="click-empty"
             phx-value-pile="foundation"
             phx-value-index="<%= "#{index}" %>"
             class="card">
    </div></li>
    """
  end
  def render_card(assigns, _, _, _) do 
    ~L"""
    <li><div class="card"></div></li>
    """
  end

  def render(assigns) do
    {reserve,tableau,foundation } = assigns.game
    {deck,waste} = reserve
    ~L"""
    <center>
      <div class="playingCards inline">
        <ul class="deck inline">
          <%= if deck do %>
            <%= render_card(assigns, :deck, :back) %>
          <% end %>
        </ul>
      </div>

      <div class="playingCards inline">
        <ul class="deck inline">
          <%= for {suit, rank} = card  <- Enum.reverse(waste) do %>
            <%= render_card(assigns, :deck, card, 0) %>
          <% end %>
        </ul>
      </div>

      <%= for {foundation, idx}  <- Enum.with_index(foundation) do %>
        <div class="playingCards inline">
          <ul class="deck inline">
          <%= render_card(assigns, :foundation, nil) %>
          <%= for {suit, rank} = card <- Enum.reverse(foundation) do %>
            <%= render_card(assigns, :foundation, card, idx) %>
          <% end %>
          </ul>
        </div>
      <% end %>
    </center>

    <center phx-click="unselect">
      <%= for {{invisible, visible}, idx}  <- Enum.with_index(tableau) do %>
        <div class="playingCards inline">
          <ul class="tableau">
            <%= for card  <- invisible do %>
              <%= render_card(assigns, :tableau, :back, idx) %>
            <% end %>
            <%= for {suit, rank} = card  <- Enum.reverse(visible) do %>
              <%= render_card(assigns, :tableau, card, idx) %>
            <% end %>
          </ul>
        </div>
      <% end %>
    </center>
    """
  end

  #TODO need this when multiple moves possible for A
  def handle_event("click-empty", params, socket) do
    IO.inspect(params)
    clicked = socket.assigns.clicked
    moves = socket.assigns.game
          |> Game.possible_moves()
          |> IO.inspect()
          |> filter_by_clicked(params, clicked)
          |> IO.inspect()
          |> check_possible_moves(params)
          |> IO.inspect()
    if len(moves) == 1 do
      socket = assign(socket, :game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
      socket = assign(socket, :clicked, nil)
      {:noreply, socket}
    else
      socket = assign(socket, :clicked, format_card(params))
      {:noreply, socket}
    end
  end
  def handle_event("click", params, socket) do
    IO.inspect(params)
    clicked = socket.assigns.clicked
    moves = socket.assigns.game
          |> Game.possible_moves()
          |> IO.inspect()
          |> filter_by_clicked(params, clicked)
          |> IO.inspect()
          |> check_possible_moves(params)
          |> IO.inspect()
    if len(moves) == 1 do
      socket = assign(socket, :game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
      socket = assign(socket, :clicked, nil)
      {:noreply, socket}
    else
      socket = assign(socket, :clicked, format_card(params))
      {:noreply, socket}
    end
  end
  def handle_event("click-deck", _, socket) do
    socket = assign(socket, :game, Game.turn(socket.assigns.game))
    {:noreply, socket}
  end
  def handle_event("unselect", _, socket) do
    socket = assign(socket, :clicked, nil)
    {:noreply, socket}
  end

  def check_possible_moves(moves, %{"rank" => rank, "suit" => suit, "index" => index, "pile" => pile_type} = params) do
    moves
    |> Enum.filter(fn {pile_from, f_idx, pile_to, t_idx, _card} ->
      f_idx == String.to_integer(index) and Atom.to_string(pile_from) == pile_type
    end)
  end

  def filter_by_clicked(moves, _params, nil), do: moves
  def filter_by_clicked(moves, %{"index" => index, "pile" => pile_type} = params, clicked) do
    moves 
    |> Enum.filter(fn {pile_from, f_idx, pile_to, t_idx, card} ->
      IO.inspect(clicked)
      IO.inspect(card)
      IO.inspect(params)
      IO.inspect(moves)
      IO.inspect({t_idx == String.to_integer(index) , Atom.to_string(pile_to) == pile_type , card == clicked} )
      t_idx == String.to_integer(index) and Atom.to_string(pile_to) == pile_type and card == clicked
    end)
  end
  def format_card(%{"rank" => rank, "suit" => suit}) do
      {String.to_existing_atom(suit), String.to_integer(rank)}
  end
  def len(nil), do: 0
  def len(list) when is_tuple(list), do: 1
  def len(list) when is_list(list), do: length(list)
end

