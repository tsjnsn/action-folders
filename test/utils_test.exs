defmodule AF.UtilsTest do
  use ExUnit.Case
  
  @base_dir "ActionFoldersTestDir"
  @file Path.join(@base_dir, "sample.file")
  @script_name_win "sample script.bat"
  @script_name_unix "sample script.exs"
  
  defp script_name do
    case :os.type do
      {:win32, _} -> @script_name_win
      {:unix, _} -> @script_name_unix
    end
  end

  defp args do
    [ script_name ]
  end
  
  test "can call an action" do
    assert {:ok, _} = AF.Utils.act("ActionFoldersTestDir/sample.file", "elixir", args, @base_dir)
  end
  
  #test "can call an action on relatively path'd script" do
    #  assert {:ok, _} = AF.Utils.act(@file, @command_relative, @base_dir)
    #end
  
end
