defmodule Master do
  @moduledoc false
  

  use GenServer

  def start_link(opts) when is_tuple(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init({numNodes,numRequests}) do
    {:ok, {numNodes,numRequests}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end