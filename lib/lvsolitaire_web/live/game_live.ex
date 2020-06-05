defmodule LVSolitaireWeb.GameLive do
  @moduledoc """
  Frontend logic
  """
  use Phoenix.LiveView
  alias Solitaire.Game, as: Game
  alias Solitaire.Deck, as: Deck

  @ranks [:a, 2, 3, 4, 5, 6, 7, 8, 9, 10, :j, :q, :k]
  def num_to_rank(rank), do: Enum.at(@ranks, rank - 1)

  def mount(_params, _session, socket) do
    game = Deck.new
           |> Deck.shuffle(Enum.random(0..1))
           |> Game.new
    socket = assign(socket, :game, game)
    socket = assign(socket, :clicked, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <center>
      <%  {reserve,tableau,foundation } = assigns.game %>
      <%  {deck,waste} = reserve %>
      <div class="playingCards inline">
        <ul class="deck inline">
          <%= if len(deck)>0 do %>
            <%= for {suit, rank} = card  <- deck do %>
              <%= render_card(assigns, :deck, :back) %>
            <% end %>
          <% else %>
            <%= render_card(assigns, :deck, nil) %>
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
          <%= render_card(assigns, :foundation, nil, idx) %>
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
            <%= if len(invisible)==0 and len(visible)==0 do %>
              <%= render_card(assigns, :tableau, :nil, idx) %>
            <% else %>
              <%= for card  <- invisible do %>
                <%= render_card(assigns, :tableau, :back, idx) %>
              <% end %>
              <%= for {suit, rank} = card  <- Enum.reverse(visible) do %>
                <%= render_card(assigns, :tableau, card, idx) %>
              <% end %>
            <% end %>
          </ul>
        </div>
      <% end %>
    </center>
    """
  end

  def render_card(assigns, pile_type, card, index \\ nil) 
  def render_card(assigns, pile_type, {suit, rank} = card, index) do 
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
  def render_card(assigns, pile, _, index) do 
    ~L"""
    <li><div phx-click="click-empty"
             phx-value-pile="<%= pile %>"
             phx-value-index="<%= index %>"
             class="placeholder">
    </div></li>
    """
  end
  def render_card(assigns, _, _, _) do 
    ~L"""
    <li><div phx-click="moves" class="card"></div></li>
    """
  end

  def focus?(%{clicked: clicked}, clicked), do: "focus"
  def focus?(%{clicked: _}, _), do: ""

  def possible_moves(socket), do: Game.possible_moves(socket.assigns.game)
  #TODO fix when moveng card valid card to different pile
  def handle_event("click-empty", params, socket) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, socket.assigns.clicked)
    |> handle_clicked_empty(params, socket)
  end
  def handle_clicked_empty(moves, params, socket) when length(moves) == 0 do
    socket
    |> assign(:clicked, format_card(params))
    |> return_socket()
  end
  def handle_clicked_empty(moves,params, socket) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
    |> return_socket()
  end
  def handle_event("click", params, socket) do
    handle_clicked(params, socket, socket.assigns.clicked)
  end
  def handle_clicked(params, socket, nil) do
    socket
    |> possible_moves()
    |> check_possible_moves(params)
    |> perform_move_with_unselected_card(socket, params)
    |> return_socket()
  end

  def perform_move_with_unselected_card(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end
  def perform_move_with_unselected_card(moves, socket, params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end
  def handle_clicked(params, socket, clicked) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, clicked)
    |> perform_move_with_selected_card(socket, params)
    |> return_socket()
  end

  def perform_move_with_selected_card(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end 

  def perform_move_with_selected_card(moves, socket, params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end

  def return_socket(socket), do: {:noreply, socket}

  def handle_event("click-deck", _, socket) do
    {{deck, _}, _, _} = socket.assigns.game
    handle_deck_click(socket, deck)
  end

  def handle_deck_click(socket, deck) when length(deck) == 0 do
    socket
    |> return_socket()
  end
  def handle_deck_click(socket, deck) do
    socket
    |> assign(:game, Game.turn(socket.assigns.game))
    |> return_socket()
  end

  def handle_event("unselect", _, socket) do
    socket
    |> assign( :clicked, nil)
    |> return_socket()
  end

  def check_possible_moves(moves, %{"index" => index, "pile" => pile_type} = params) do
    moves
    |> Enum.filter(fn {pile_from, from_idx, _pile_to, _to_idx, _card} ->
      from_idx == String.to_integer(index) and Atom.to_string(pile_from) == pile_type
    end)
  end

  def filter_by_clicked(moves, _params, nil), do: moves
  def filter_by_clicked(moves, %{"index" => index, "pile" => pile_type} = params, clicked) do
    moves 
    |> Enum.filter(fn {_pile_from, _from_idx, pile_to, to_idx, card} ->
      to_idx == String.to_integer(index) and Atom.to_string(pile_to) == pile_type and card == clicked
    end)
  end
  def format_card(%{"rank" => rank, "suit" => suit}) do
    {String.to_existing_atom(suit), String.to_integer(rank)}
  end
  def format_card(_), do: nil

  def len(nil), do: 0
  def len(list) when is_tuple(list), do: 1
  def len(list) when is_list(list), do: length(list)
end

