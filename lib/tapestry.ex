defmodule Tapestry do

  def start(_type, _args) do
    System.argv() |> main()
  end

  def main(args) do
    if length(args) != 2 do
      IO.puts("Insufficient number of parameters. Terminating")
      System.halt(1)
    end

    [numnodes, nreq] = args

    numnodes = Integer.parse(numnodes)


    nreq = Integer.parse(nreq)

    n = elem(numnodes,0)

    nodeids = []

    #maintain a mapping from pid to their respective hashes just in case
    phashmap = %{}


    nodeids = for i <- 0..n-1 do
      #Get an 8 character random hash
      hashed =  :crypto.strong_rand_bytes(4) |> Base.encode16
      initstate = {hashed, nreq}

      pid = Actor.start_node(initstate)
      Map.put(phashmap, pid, hashed)
      [pid|nodeids]
    end

    nodeids = List.flatten(nodeids)

    for i <- nodeids do
      
    end


  end
end
