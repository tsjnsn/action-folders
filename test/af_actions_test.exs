defmodule AF.ActionsTest do
  use ExUnit.Case
  
  @base_folder "ActionFoldersTestDir"
  @sample_command_unix Path.expand("#{@base_folder}/sample script.exs")
  @sample_script_relative_unix "#{@base_folder}/sample script.exs"
  @sample_script_win Path.expand("#{@base_folder}/sample script.bat")
  @sample_script_relative_win "#{@base_folder}/sample script.bat"
  @sample_file "#{@base_folder}/sample.file"
  @sample_newfile_in_actionfolder "#{@base_folder}/testfolder.act/add_test.file"
  
  test "can call an action" do
    script =
    case :os.type do
      {:win32, _} -> @sample_script_win
      {:unix, _} -> @sample_script_unix
    end
    
    assert {:ok, _} = AF.Actions.act(@sample_file, )
  end
  
  test "can call an action on relatively path'd script" do
    # call action on file
    # check if file was changed appropriately
    script =
    case :os.type do
      {:win32, _} -> @sample_script_relative_win
      {:unix, _} -> @sample_script_relative_unix
    end
    
    assert {:ok, _} = AF.Actions.act_on_file(script, @sample_file)
  end
  
end
