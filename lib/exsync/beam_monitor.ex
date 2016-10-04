defmodule ExSync.BeamMonitor do
  use ExFSWatch, dirs: ExSync.Config.beam_dirs

  def callback(:stop) do
    IO.puts "STOP"
  end

  def callback(file_path, events) do
    if (Path.extname file_path) in [".beam"] do
      { :created  in events,
        :removed  in events,
        :modified in events,
        file_path |> File.exists?,
      }
   |> case do
        {_, _, true, true} ->   # update
          log(file_path, "reload")
          ExSync.Utils.reload file_path
        {true, true, _, false} -> # temp file
          nil
        {_, true, _, false} ->  # remove
          log(file_path, "unload")
          ExSync.Utils.unload file_path
        _ ->                    # create
          nil
      end
    end
  end

  defp log(file_path, mode) do
    if ExSync.Config.verbose? do
      IO.puts "#{mode} module #{format_name(file_path)}"
    end
  end

  defp format_name(path) do
    case Path.basename(path, ".beam") do
      "Elixir." <> module ->
        module
      module ->
        module
    end
  end
end
