defmodule AF.Actions do
  
  @doc """
  Tries to execute a script. If it fails predictably, it
  will return {:error, reason}
  
  It will expand the script path before running it.
  """
  def act_on_file(script, file) do
    case {File.exists?(script), File.exists?(file)} do
      {true, true} -> _act_on_file(Path.expand(script), file)
      {s?, f?} -> {:error, "Script exists: #{s?}\nFile exists: #{f?}"}
    end
  end
  
  defp _act_on_file(script, file) do
    try do
      case System.cmd(script, [file]) do
        {output, 0} -> {:ok, output}
        {output, err} -> {:error, output, err}
      end
    rescue
      e in ArgumentError -> {:error, e}
      e in ErlangError -> {:error, e}
    end
  end
  
end
