defmodule ExSync.Utils do
  base_tasks = ~w(compile compile.all compile.protocols loadpaths deps.loadpaths)
  tasks =
    Mix.Tasks.Compile.compilers()
    |> Enum.reduce(base_tasks, &["compile.#{&1}" | &2])

  @tasks tasks

  def recomplete do
    Enum.each(@tasks, &Mix.Task.reenable/1)
    try do
      Mix.Task.run("compile", [])
    catch
      _, _ ->
        :ok
    end
  end

  def unload(module) when is_atom(module) do
    module |> :code.purge
    module |> :code.delete
  end

  def unload(beam_path) do
    beam_path |> Path.basename(".beam") |> String.to_atom |> unload
  end

  def reload(beam_path) do      # beam file path
    file = beam_path |> to_char_list()
    {:ok, binary, _} = :erl_prim_loader.get_file file
    module = beam_path |> Path.basename(".beam") |> String.to_atom
    :code.load_binary(module, file, binary)

    # load the module
    module.module_info()
    notify(module, :reload)
  end

  defp notify(module, mode) do
    ExSync.Config.watchers()
    |> Enum.each(fn
      (fun) when is_function(fun, 2) ->
        fun.(module, mode)
      (fun) when is_function(fun, 1) and mode == :reload ->
        fun.(module)
      (fun) when is_function(fun, 0) ->
        fun.()
      (_) ->
        :ok
    end)
  end
end
