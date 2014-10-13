defmodule AF.ServerTest do
  use ExUnit.Case
  
  setup do
    {:ok, actserv} = AF.Server.start_link
    {:ok, actserv: actserv}
  end
  
  @base_folder "ActionFoldersTestDir"
  @folder_with_act "#{@base_folder}/testfolder.act"
  @deep_folder_with_act "#{@base_folder}/testfolder.act/subfolder-no-act/subsubfolder-with-act"
  @deep_folder_no_act "#{@base_folder}/testfolder.act/subfolder-no-act"
  @nonexistant_folder "#{@base_folder}/this/should/not/exist!"
  @sample_file "#{@base_folder}/sample.file"
  
  # test "can't create server with non-existant argument", %{actserv: actserv} do
  #   assert {:error, _} = GenServer.call(actserv, {:watch_folder, [path: @nonexistant_folder]})
  # end
  
  # test "can't create server with file argument", %{actserv: actserv} do
  #   assert {:error, _} = GenServer.call(actserv, {:watch_folder, [path: @sample_file]})
  # end
  
  test "can watch new folder", %{actserv: actserv} do
    assert {:ok} = GenServer.call(actserv, {:watch_folder, [path: @base_folder]})
  end
  
  test "can get the list of folders which have actions (non-recursive)", %{actserv: actserv} do
    assert {:ok} = GenServer.call(actserv, {:watch_folder, [path: @base_folder]})
    
    action_folders = GenServer.call(actserv, :list_action_folders)
    assert is_list action_folders
    assert not @deep_folder_with_act in action_folders
  end
  
  test "can get the list of folders which have actions (recursive)", %{actserv: actserv} do
    assert {:ok} = GenServer.call(actserv, {:watch_folder, [path: @base_folder, flags: [:recursive]]})
    
    action_folders = GenServer.call(actserv, :list_action_folders)
    assert is_list action_folders
    assert @deep_folder_with_act in action_folders
  end
end
