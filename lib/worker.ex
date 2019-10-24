defmodule Worker do
  @moduledoc false
  use GenServer

  def start_link(opts)  when is_tuple(opts)do
    #IO.inspect(opts)
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
    #changed the timeout to infinity so that the process doesn't timeout while debugging
    GenServer.call(pid, {:handle_map, map}, :infinity)
  end
  def handle_call({:handle_map, map},
        _from,
        {master_pid, self_index, _index_2_pid_map, _local_table, msg_fail_prob}) do
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

        #IO.inspect(levels_no_self, label: "Levels: ")

        #All the hashes for all the nodes
        hashes = Map.keys(map)

        localmap = Map.new()

        self_index_integer = elem(Integer.parse(self_index,16),0)

        #local = []

        local_int_val = elem(Integer.parse(self_index,16),0)


        #this block of code is unsustainable because of essentially a nested for loop. 
        #Takes a really long time to finish.
        #Either that or the arithmetic is taking a long time
        #gotta think of a better way
        local = Enum.map(
          0..Enum.count(hashes)-1,
          fn i ->
            Enum.map(
              0..Enum.count(levels_no_self)-1,
              fn j ->
                if (String.starts_with?( Enum.at(hashes,i), Enum.at(levels_no_self,j))) do
                  mapkey = Enum.at(levels_no_self,j)
                  mapval = Enum.at(hashes,i)
                  if Map.has_key?(localmap, mapkey) do
                    #Current hash in the loop
                    curr_hash = Enum.at(hashes,i)
                    #Existing hash value in the map
                    existing_hash = Map.get(localmap, mapkey)
                    #Integer.parse returns a tuple with the 0th index containing the actual value
                    existing_int_val = elem(Integer.parse(existing_hash,16), 0)
                    #Current hash's int value
                    curr_int_val = elem(Integer.parse(curr_hash,16), 0)
                    #Distance is always non negative
                    prev_dist = abs(existing_int_val - local_int_val)

                    new_dist = abs(curr_int_val - local_int_val)

                    #update the map only if the new distance is strictly less than prev_dist
                    if new_dist < prev_dist do
                      localmap = Map.replace!(localmap, mapkey, curr_hash)
                    end
                  else
                    localmap = Map.put(localmap, mapkey, mapval)

                  end
                end
              end
            )
          end
        )
        

        #local is a list of maps
        local = List.flatten(local)
        #remove nil values from the resulting list
        local = Enum.reject(local, &is_nil/1)

        local_table = []

        #convert each map into a list
        local_table = for i <- local do
          j = Map.to_list(i)
          [j|local_table]
        end
        
        #flatten the list and convert the whole list into a map
        local_table = local_table |> List.flatten() |> Enum.into(%{})
        #IO.inspect(length(local_table), label: "Length of local table")
        #IO.puts("Local Table:")
        IO.inspect(local_table, label: "Local Table\n")

    {:reply, :ok, {master_pid, self_index, map, local_table, msg_fail_prob}}
  end

  def route_to_node({sourceid, sourcehash, desthash}) do
    GenServer.cast(self(), {sourceid, sourcehash, desthash})
  end

  def handle_cast({sourceid, sourcehash, desthash}, 
  {master_pid, self_index, map, local_table, msg_fail_prob}) do

  end
end
