defmodule Master do
  @moduledoc false
  

  use GenServer

  def start_link(opts) when is_tuple(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

#  def init({alive_count}) do
  def init({numNodes, numRequests}) do
    all_hops = []
    {:ok, {numNodes, numRequests,all_hops}}
#    {:ok, {numNodes, max_hop}}
  end

  def decrement_alive(pid, hops) do
    GenServer.cast(pid, {:decrement_alive, 1, hops})
  end


  @impl true
  def handle_cast({:decrement_alive, count, hops}, {numNodes, numRequests,all_hops}) do
    ## Count will be -1 in this project.
    new_all_hops = all_hops ++[hops]
    ## If no node is now alive, we're done.
    if Enum.count(all_hops)+1 == numRequests*numNodes do
      ## Wait a bit for all print messages to flush out :)
      Process.sleep(2000)
      IO.puts("Max number of hops is: ")
      IO.inspect(Enum.max(new_all_hops))
      IO.puts("Master# All actors finished!")

      Process.exit(self(), :SUCCESS)
    else
      #      IO.puts("Master# alive actors: #{new_numRequests}")
      {:noreply, { numNodes,numRequests, new_all_hops}}
    end
  end

end