defmodule Worker do
  @moduledoc false
  


  use GenServer

  def start_link(opts)  when is_tuple(opts)do
    IO.inspect(opts)
    GenServer.start_link(__MODULE__, opts)
  end

  def init({master_pid, self_index, index_2_pid_map, local_table, msg_fail_prob}) do

    {:ok, {master_pid, self_index, index_2_pid_map, local_table, msg_fail_prob}}

  end

  ## Interface.

#  def request(pid, request_hops) do
#    GenServer.cast(pid, {:handle_gossip, request_hops})
#  end
  def handle_map(pid, map) do
    GenServer.call(pid, {:handle_map, map}, 10_000)
  end
  def handle_call({:handle_map, map},
        _from,
        {master_pid, self_index, index_2_pid_map, local_table, msg_fail_prob}) do
        #list of all the hex digits
        hex = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        #making all the prefixes based on the self_index
        self_index_prefix = Enum.map(0..byte_size(self_index)-1, fn i -> binary_part(self_index,0,i) end)
        #building all the possible levels for the local tables. Level 0, nothing is matching, and level 7, 7 digit matching.
        levels = for j <- 0..7 do
          level = Enum.map(0..15, fn i->Enum.at(self_index_prefix,j)<>Enum.at(hex,i) end)
        end
        levels_flatten = List.flatten(levels)
        #remove the self_index_prefix from levels
        levels_no_self = levels_flatten -- self_index_prefix

        #All the hashes for all the nodes
        hashes = Map.keys(map)

        local = Enum.map(
          0..Enum.count(hashes)-1,
          fn i ->
            Enum.map(
              0..Enum.count(levels_no_self)-1,
              fn j ->
                if (String.starts_with?( Enum.at(hashes,i), Enum.at(levels_no_self,j))) do
                  {Enum.at(levels_no_self,j), Enum.at(hashes,i)}
                end
              end
            )
          end
        )
        #cleaning the data in local by removing nil and add it to the map
        local_table = local |> List.flatten |> Enum.filter(& !is_nil(&1)) |> Enum.into(%{})

        IO.puts("Local Table:")
        IO.inspect(local_table)

    {:reply, :ok, {master_pid, self_index, map, local_table, msg_fail_prob}}
  end
end