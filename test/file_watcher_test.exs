defmodule FileWatcherTest do
  use ExUnit.Case, async: true
  
  @testfolder "ActionFoldersTestDir/testfolder.act"
  @tmp "ActionFoldersTestDir/testfolder.act/temp"
 
  # run once at the beginning
  setup_all do
    # remove temporary directories, and also remake the structure
    File.rm_rf(@tmp)
    File.mkdir(@tmp)
  end
  
  setup do
    # start the watcher server and pass state back
    { :ok, watcher } = GenServer.start_link(FileWatcher, :ok)
    { :ok, watcher: watcher }
  end
  
  test "can create watcher", %{watcher: watcher} do
    assert watcher
  end
  
  test "can add folder to be watched", %{watcher: watcher} do
    parent = self()
    callback_fileischanged = fn new_files -> send(parent, new_files) end
    
    {:ok, reply} = FileWatcher.watch_folder(watcher, @tmp, [], callback_fileischanged)
    
    # creates a file path using the current timestamp and sequence number provided
    create_file = fn seq -> Path.join(@tmp, inspect(:erlang.now())) <> " #{seq}" end
    
    File.touch( create_file.(2) )
    receive_files_changed_sync()
    
    File.touch( create_file.(3) )
    receive_files_changed_sync()
    
    Process.exit(reply.monitor, :kill)
    
  end
  
  test "can watch a folder" do
    parent = self()
    pid = spawn fn -> FileWatcher.scan_forever(parent, @tmp, []) end
    
    create_file = fn seq -> Path.join(@tmp, inspect(:erlang.now())) <> " #{seq}" end
    
    File.touch( create_file.(0) )
    receive_files_changed_sync()
    
    File.touch( create_file.(1) )
    receive_files_changed_sync()
    
    Process.exit(pid, :kill)
  end

  
  defp receive_files_changed_sync() do
    receive do
      new_files ->
        new_files
    after
      1_000 -> nil
    end
    |> assert
  end

end
