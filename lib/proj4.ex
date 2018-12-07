defmodule BitcoinSimulator do
  use Supervisor

  def main(num_users, max_blocks) do

    {:ok, super_pid} = start_link(num_users)
    #IO.puts "super_pid:"
    #IO.puts "#{inspect super_pid}"

    [user_map, miner_map] = make_id_map(%{}, %{}, Supervisor.which_children(super_pid))

    #IO.puts "user_pids:"
    Enum.each  user_map,  fn {_user_num, user_pid} ->
      #IO.puts "#{inspect user_pid}"
      GenServer.call(user_pid, {:set_maps, user_map, miner_map})
    end

    #IO.puts "miner_pids:"
    Enum.each  miner_map,  fn {_miner_num, miner_pid} ->
      #IO.puts  "#{inspect miner_pid}"
      GenServer.call(miner_pid, {:set_maps, user_map, miner_map})
    end

    blockchain = make_genesis_transaction(user_map, miner_map)

    make_transactions(user_map, 1)

    Enum.each  miner_map,  fn {_miner_num, miner_pid}  ->
      GenServer.cast(miner_pid, {:mine_transactions})
    end

    listen(user_map, miner_map, [], blockchain, max_blocks)
  end

  def generate_nonce(string, nonce) do
    hash = :crypto.hash(:sha256, string <> ";" <> Integer.to_string(nonce)) |> Base.encode16()
    if String.slice(hash, 0, 2)  == "00" do
      [nonce, hash]
    else
      generate_nonce(string, nonce+1)
    end
  end

  def make_genesis_transaction(user_map\\%{}, miner_map\\%{}) do
    block = %{}
    block = Map.put(block, :block_num, 0)
    genesis_transaction = Map.put(%{}, :id, 0)
    genesis_transaction = Map.put(genesis_transaction, :sender, 0)
    genesis_transaction = Map.put(genesis_transaction, :reciever, 0)
    genesis_transaction = Map.put(genesis_transaction, :amount, 100000)
    block = Map.put(block, :data, [genesis_transaction])
    prev_hash = "0000000000000000000000000000000000000000000000000000000000000000"
    block = Map.put(block, :prev, prev_hash)
    block_string = "0;100000;0;0;0;0000000000000000000000000000000000000000000000000000000000000000"
    [nonce, hash] = generate_nonce(block_string, 0)
    block = Map.put(block, :nonce, nonce)
    block = Map.put(block, :hash, hash)
    blockchain = [block]

    Enum.each user_map,  fn {_user_num, user_pid} ->
      GenServer.cast(user_pid, {:update_blockchain, blockchain})
    end

    Enum.each miner_map,  fn {_miner_num, miner_pid} ->
      GenServer.cast(miner_pid, {:update_blockchain, blockchain})
    end

    blockchain
  end

  defp make_transactions(user_map, curr_tran_num) do
    if curr_tran_num < 17 do
      sender = 11
      rec = 12
      GenServer.cast(Map.get(user_map, sender), {:make_transaction, rec, 2, Integer.to_string(:os.system_time(:millisecond)) <> ":" <> Integer.to_string(sender) <> " sends " <> Integer.to_string(2) <> " DOSCoins to " <> Integer.to_string(rec)})
      make_transactions(user_map, curr_tran_num+1)
    end
  end

  def is_valid_block([tran | trans], pending_transactions, flag\\true) do
    cond do
      length(trans) == 0 ->
        index = Enum.find_index(pending_transactions, fn pending_transaction ->
          tran.id == pending_transaction.id
        end)
        index != nil
      flag ->
        index = Enum.find_index(pending_transactions, fn pending_transaction ->
          tran.id == pending_transaction.id
        end)
        is_valid_block(trans, pending_transactions, index != nil)
      true ->
        false
    end
  end

  defp listen(user_map, miner_map, pending_transactions, blockchain, max_blocks\\3) do
    receive do
      {:block_created, block, miner_num}->
        [blockchain, pending_transactions] =
          if is_valid_block(block.data, pending_transactions) do
            IO.puts "Miner #{miner_num} has added block with 5 transactions successfully"
            GenServer.call(Map.get(miner_map, block.miner_num), {:credit, 5})
            IO.puts "Miner #{miner_num} got 5 DOSCoins!!"
            Enum.each(block.data, fn tran ->
              GenServer.call(Map.get(user_map, tran.reciever), {:credit, tran.amount})
              rec_wallet = GenServer.call(Map.get(user_map, tran.reciever), {:get_amount})
              IO.puts "Wallet of reciever #{tran.reciever} has #{rec_wallet} DOSCoins"
            end)
            pending_transactions =
              Enum.reject(pending_transactions, fn pending_tran ->
                Enum.any?(block.data, fn tran ->
                  tran.id == pending_tran.id
                end)
              end)
            blockchain = blockchain ++ [block]
            Enum.each user_map,  fn {_user_num, user_pid} ->
              GenServer.cast(user_pid, {:update_blockchain, blockchain})
            end

            Enum.each miner_map,  fn {_miner_num, miner_pid} ->
              GenServer.cast(miner_pid, {:update_blockchain, blockchain})
            end

            [blockchain, pending_transactions]
          else
            [blockchain, pending_transactions]
          end
        if length(blockchain) < max_blocks do
          listen(user_map, miner_map, pending_transactions, blockchain)
        else
          Enum.each  miner_map,  fn {miner_num, miner_pid} ->
          #   GenServer.call(miner_pid, {:print_state})
            amount = GenServer.call(miner_pid, {:get_amount})
            IO.puts "Miner #{miner_num} has #{amount} DOSCoins in the wallet"
          end

          Enum.each  user_map,  fn {user_num, user_pid} ->
            # GenServer.call(user_pid, {:print_state})
            amount = GenServer.call(user_pid, {:get_amount})
            IO.puts "User #{user_num} has #{amount} DOSCoins in the wallet"
          end
          IO.puts "15 transactions and 3 blocks complete"
          IO.puts "pending transactions: #{inspect pending_transactions}"
          IO.puts "blockchain: #{inspect blockchain}"
        end
      {:push_transaction, transaction} ->
        pending_transactions = pending_transactions ++ [transaction]
        # IO.inspect pending_transactions
        listen(user_map, miner_map, pending_transactions, blockchain)
      {:fetch_transactions, miner_pid} ->
        GenServer.cast(miner_pid, {:update_pending_transactions, pending_transactions})
        listen(user_map, miner_map, pending_transactions, blockchain)
      {:get_blockchain, pid}->
        Process.send(pid, {:latest_blockchain, blockchain}, [])
        listen(user_map, miner_map, pending_transactions, blockchain)
    end
  end

  def start_link(num_users) do
    children = get_children_list([], 1, 10+num_users)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp get_children_list(children_list, currNode, totalNodes) do
    cond do
      totalNodes == 0 ->
        children_list
      currNode <= 10 ->
        [%{
          id: currNode,
          start: {Miner, :start_link, [%{:id => currNode, :user_map => %{}, :miner_num => currNode, :amount => 0, :miner_map => %{}, :blockchain => [], :pending_transactions => [], :super_pid => self()}]}
        }] ++ get_children_list(children_list, currNode+1, totalNodes - 1)
      true ->
          [%{
          id: currNode,
          start: {User, :start_link, [%{:id => currNode, :user_num => currNode, :amount => 100, :user_map => %{}, :miner_map => %{}, :blockchain => [], :super_pid => self()}]}
          }] ++ get_children_list(children_list, currNode+1, totalNodes - 1)
    end
  end

  defp make_id_map(user_map, miner_map, [node_obj | node_objs]) do
    {_, node_pid, _, _} = node_obj
    node_id = GenServer.call(node_pid, {:get_id})
    [user_map, miner_map] =
      if(node_id <= 10) do
        [user_map, Map.put(miner_map, node_id, node_pid)]
      else
        [Map.put(user_map, node_id, node_pid), miner_map]
      end
    make_id_map(user_map, miner_map, node_objs)
  end

  defp make_id_map(user_map, miner_map, []) do
    [user_map, miner_map]
  end

  def init(args) do
    IO.puts "args: #{inspect args}"
    {:ok, args}
  end
end

defmodule User do
  use GenServer
  def start_link(state) do
    {private_key, public_key} = :crypto.generate_key(:ecdh, :secp256k1)
    state = Map.put(state, :private_key, Base.encode16(private_key))
    state = Map.put(state, :public_key, Base.encode16(public_key))
    #IO.puts "Wallet created with 100 DOSCoins for user #{state.user_num}"
    GenServer.start_link(__MODULE__, state)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:make_transaction, reciever, amount, transaction_id}, state) do
    new_transaction = Map.put(%{}, :id, transaction_id)
    new_transaction = Map.put(new_transaction, :sender, state.user_num)
    new_transaction = Map.put(new_transaction, :reciever, reciever)
    new_transaction = Map.put(new_transaction, :amount, amount)
    is_valid_transaction = GenServer.call(Map.get(state.user_map, reciever), {:verify, state.public_key, new_transaction})
    state=
      if(is_valid_transaction) do
        Process.send(state.super_pid, {:push_transaction, new_transaction}, [])
        state = Map.put(state, :amount, state.amount - amount)
        IO.puts "Wallet of sender #{state.user_num} has #{state.amount} DOSCoins"
        state
      else
        state
      end
    {:noreply, state}
  end

  def handle_cast({:update_blockchain, updated_blockchain}, state) do
    state = Map.put(state, :blockchain, updated_blockchain)
    # IO.inspect state
    {:noreply, state}
  end

  def handle_call({:sign, message}, _from, state) do
    {:reply, :crypto.sign(:ecdsa, :sha256, message, [state.private_key, :secp256k1]), state}
  end

  def handle_call({:verify, _public_key, message}, _from, state) do
    result = message.amount <= 5
    # result = GenServer.call(Map.get(state.user_map, message.sender), {:get_amount}) >= message.amount
    # result = :crypto.verify(:ecdsa, :sha256, message, [public_key, :secp256k1])
    if result do
      IO.puts "User #{state.user_num} verfified transaction of #{message.amount} DOSCoins from #{message.sender} to #{message.reciever}"
    end
    {:reply, result, state}
  end

  def handle_call({:set_maps, user_map, miner_map}, _from, state) do
    state = Map.put(state, :user_map, user_map)
    state = Map.put(state, :miner_map, miner_map)
    # IO.inspect state
    {:reply, :ok, state}
  end

  def handle_call({:credit, amount}, _from, state) do
    state = Map.put(state, :amount, state.amount + amount)
    {:reply, :ok, state}
  end

  def handle_call({:get_id}, _from, state) do
    {:reply, state.id, state}
  end

  def handle_call({:get_amount}, _from, state) do
    {:reply, state.amount, state}
  end

  def handle_call({:print_state}, _from, state) do
    IO.inspect state
    {:reply, :ok, state}
  end
end

defmodule Miner do
  use GenServer
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(args) do
    {:ok, args}
  end

  defp to_string([tran | trans], string) do
    if length(trans) == 0 do
      string
    else
      to_string(trans, string <> ";" <> Integer.to_string(tran.amount) <> "|" <> tran.id <> "|" <>  Integer.to_string(tran.reciever) <> "|" <>  Integer.to_string(tran.sender))
    end
  end

  def generate_nonce(string, nonce) do
    hash = :crypto.hash(:sha256, string <> ";" <> Integer.to_string(nonce)) |> Base.encode16()
    if String.slice(hash, 0, 2)  == "00" do
      [nonce, hash]
    else
      generate_nonce(string, nonce+1)
    end
  end

  def create_block(transactionList, state) do
    block = %{}
    block_num = length(state.blockchain)
    block = Map.put(block, :block_num, block_num)
    block = Map.put(block, :miner_num, state.miner_num)
    block = Map.put(block, :data, transactionList)
    prev_hash = Enum.at(state.blockchain, 0).hash
    block = Map.put(block, :prev, prev_hash)
    block_string = Integer.to_string(block_num) <> ";" <> Integer.to_string(state.miner_num) <> ";" <> to_string(transactionList, "") <> ";" <> prev_hash
    [nonce, hash] = generate_nonce(block_string, 0)
    block = Map.put(block, :nonce, nonce)
    block = Map.put(block, :hash, hash)
    block
  end

  def handle_cast({:update_pending_transactions, pending_transactions}, state) do
    # IO.inspect pending_transactions
    state = Map.put(state, :pending_transactions, pending_transactions)
    if length(pending_transactions) >= 5 do
      block = create_block(Enum.take(pending_transactions, 5), state)
      Process.send(state.super_pid, {:block_created, block, state.miner_num}, [])
    end
    GenServer.cast(self(), {:mine_transactions})
    # IO.inspect state
    {:noreply, state}
  end

  def handle_cast({:mine_transactions}, state) do
    Process.send(state.super_pid, {:fetch_transactions, self()}, [])

    {:noreply, state}
  end

  def handle_cast({:update_blockchain, updated_blockchain}, state) do
    {:noreply, Map.put(state, :blockchain, updated_blockchain)}
  end

  def handle_call({:set_maps, user_map, miner_map}, _from, state) do
    state = Map.put(state, :user_map, user_map)
    state = Map.put(state, :miner_map, miner_map)
    # IO.inspect state
    {:reply, :ok, state}
  end

  def handle_call({:get_amount}, _from, state) do
    {:reply, state.amount, state}
  end

  def handle_call({:credit, amount}, _from, state) do
    state = Map.put(state, :amount, state.amount + amount)
    {:reply, :ok, state}
  end

  def handle_call({:get_id}, _from, state) do
    {:reply, state.id, state}
  end

  def handle_call({:print_state}, _from, state) do
    IO.inspect state
    {:reply, :ok, state}
  end
end

