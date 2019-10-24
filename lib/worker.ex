defmodule Worker do
  @moduledoc false
  


  use GenServer

  def start_link(opts)  when is_tuple(opts)do
    IO.inspect(opts)
    GenServer.start_link(__MODULE__, opts)
  end

  def init({master_pid, self_index, index_2_pid_map, msg_fail_prob}) do
    {:ok, {master_pid, self_index, index_2_pid_map, msg_fail_prob}}
  end

  def handle_call({:handle_map, map},
        _from,
        {master_pid, self_index, index_2_pid_map, msg_fail_prob}) do


    {:reply, :ok, {master_pid, self_index, map, msg_fail_prob}}

  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
  def handle_map(pid, map) do
    GenServer.call(pid, {:handle_map, map}, 10_000)
  end
end