defmodule SimpleTelegramBot do
  use GenServer

  alias Nadia

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: :pooler_server])
  end

  def init(state \\ []) do
    spawn fn -> handle_cast(:start_pool, state, nil) end
    {:ok, state}
  end

  def do_pool([update | updates], ts) do
    %Nadia.Model.Update{update_id: update_id, message: %Nadia.Model.Message{text: text}} = update
    IO.puts text

    do_pool(updates, ts)
  end

  def do_pool(_, ts) do
    { _, updates } = Nadia.get_updates(offset: ts, limit: 1)

    case updates do
      [_] ->
        max_update_id = Enum.max_by(updates, &(&1.update_id)).update_id
        do_pool(updates, max_update_id + 1)
      _ ->
        do_pool(updates, ts)
    end
  end

  def handle_cast(:start_pool, state, _) do
    do_pool(state, nil)
    {:noreply, state}
  end
end
