defmodule ExSync do
  def start(_, _) do
    case Mix.env do
      :dev ->
        ExSync.SrcMonitor.start
        ExSync.BeamMonitor.start
        IO.write :stderr, "ExSync started.\n"
      _ ->
        IO.write :stderr, "ExSync NOT stared. Only :dev environment is supported.\n"
    end
    {:ok, self}
  end

  def start() do
    Application.ensure_all_started(:exsync)
  end

  def add_watcher(fun) do
    ExSync.Config.watchers(fun)
  end
end
