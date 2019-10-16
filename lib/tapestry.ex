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

    n = elem(numnodes,0)

    hashes = []


    nodeids = for i <- 0..n-1 do
      pid = Actor.start_node({})
      h = Actor.setState(pid)
      [h|hashes]
    end

    hashes = List.flatten(hashes)
  end
end
