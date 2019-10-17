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

  def actMailBox() do
    receive do
      {:message_type} -> GenServer.cast(self())
        # code
    end

  end

  def handle_call() do

  end

  #broadcast node's hash to other nodes

end
