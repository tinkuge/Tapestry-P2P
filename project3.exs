defmodule Project3 do
  require Integer

  def main(args) do
    ## The probability of and actor failing.
    msg_fail_prob = 0.000

    IO.inspect(args)
    ## Check args.
    if length(args) != 2 do
      IO.puts("Insufficient number of parameters. Please enter two integers for numNodes and numRequests.")
      exit(1)
    end

    numNodes = Enum.at(args, 0) |> String.to_integer
    numRequests = Enum.at(args, 1) |> String.to_integer

    if(numNodes <= 0 || !is_integer(numNodes)) do
      IO.puts("Wrong numNodes! Please choose a integer value greater than 0.")
      exit(1)
    end

    if(numRequests <= 0 || !is_integer(numRequests)) do
      IO.puts("Wrong numRequest! Please choose a integer value greater than 0.")
      exit(1)
    end
    ## Start the Master.
    {:ok, master_pid} = Master.start_link({numNodes,numRequests})

    index_2_pid_map = Map.new()
    ## Start some actors.All actors need to know the master_pid, and their index.
    range = 0..numNodes - 1 # Range is inclusive on both sides.
#    hashIds = :crypto.strong_rand_bytes(4) |> Base.encode16
    hashIds = for i <- range do
      [] ++ :crypto.strong_rand_bytes(4) |> Base.encode16
    end
    IO.inspect(hashIds)
    ## Create actors
    actors = Enum.map(
      hashIds,
      fn hash ->
        #        {master_pid, self_index, index_2_pid_map}
        {:ok, actor_pid} = Worker.start_link({master_pid, hash, index_2_pid_map, msg_fail_prob})
        actor_pid
      end
    )
    IO.inspect(actors)
    ## Update index_2_pid_map, by using flat_map to create numNodes maps, then Enum.into actual map; because Elixir!
    index_2_pid_map_tuples = Enum.flat_map(
      range,
      fn i ->
        Map.put(Map.new(), Enum.at(hashIds, i), Enum.at(actors, i))
      end
    )
    index_2_pid_map = Enum.into(index_2_pid_map_tuples, %{})
    IO.inspect(index_2_pid_map)
    ## Also pass the pid map of all actors to each actor.
    IO.puts("Sending index_2_pid_map to all actors...")
    Enum.map(
      actors,
      fn actor -> Worker.handle_map(actor, index_2_pid_map) end
    )

  end
end

System.argv() |> Project3.main()