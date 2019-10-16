defmodule Actor do
  use GenServer

  def start_node(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, arg)
    pid

  end

  def init(arg) do

    {:ok, arg}
  end

  def setState(pid) do
    GenServer.call(pid)
  end


  #any changes to the default states will be done later. For now it stores the hash of curent node
  def handle_call(state) do
    hashed =  :crypto.strong_rand_bytes(4) |> Base.encode16
    {:noreply, hashed}
  end
end
