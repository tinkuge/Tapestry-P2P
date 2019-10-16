defmodule Actor do
  use GenServer

  def start_node(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, arg)
    pid

  end

  def init(arg) do

    {:ok, arg}
  end

  #listening post

  

  #broadcast node's hash to other nodes

end
