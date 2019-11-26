defmodule LVSolitaireWeb.GameView do
  use LVSolitaireWeb, :view
  use Phoenix.LiveView
  import LVSolitaireWeb.LVSolitaireLive

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
  def render_card(assigns, pile, _, index) do 
    ~L"""
    <li><div phx-click="click-empty"
             phx-value-pile="<%= pile %>"
             phx-value-index="<%= index %>"
             class="card">
    </div></li>
    """
  end
  def render_card(assigns, _, _, _) do 
    ~L"""
    <li><div phx-click="moves" class="card"></div></li>
    """
  end
end
