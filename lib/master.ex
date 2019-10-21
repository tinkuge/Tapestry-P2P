defmodule Master do
  @moduledoc false
  

  use GenServer

  def start_link(opts) when is_tuple(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

#  def init({alive_count}) do
  def init({numNodes,numRequests}) do
    max_hop = 0
    {:ok, {numNodes,numRequests, max_hop}}
#    {:ok, {alive_count, max_hop}}
  end
  def increment_alive(pid) do
    GenServer.cast(pid, {:increment_alive, 1})
  end

  def decrement_alive(pid) do
    GenServer.cast(pid, {:increment_alive, -1})
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
  @impl true
  def handle_cast({:increment_alive, count}, {alive_count}) do
    ## Count will be -1 in this project.
    new_live_count = alive_count + count
    ## If no node is now alive, we're done.
    if new_live_count == 0 do
      ## Wait a bit for all print messages to flush out :)
      Process.sleep(2000)
      IO.puts("Master# All actors finished!")
      Process.exit(self(), :SUCCESS)
    else
      #      IO.puts("Master# alive actors: #{new_live_count}")
      {:noreply, { new_live_count}}
    end
  end

end