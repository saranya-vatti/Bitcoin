defmodule BitcoinSimulatorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest BitcoinSimulator

  test "test the function that creates nonce and hash in the simulator" do
    [nonce, hash] = BitcoinSimulator.generate_nonce("test", 0)
    assert nonce == 162
    assert hash == "009C28C55FA6A2C82D479E85E8363CAFE180DBCB13D15BE50A64C2C3EC67C692"
  end

  test "test the function that creates nonce and hash in each miner" do
    [nonce, hash] = Miner.generate_nonce("test", 0)
    assert nonce == 162
    assert hash == "009C28C55FA6A2C82D479E85E8363CAFE180DBCB13D15BE50A64C2C3EC67C692"
  end

  test "test the genesis transaction" do
    blockchain = BitcoinSimulator.make_genesis_transaction()
    assert length(blockchain) == 1
    genesis_block = Enum.fetch!(blockchain, 0)
    assert genesis_block.block_num == 0
    assert length(genesis_block.data) == 1
    genesis_transaction = Enum.fetch!(genesis_block.data, 0)
    assert genesis_transaction.id == 0
    assert genesis_transaction.sender == 0
    assert genesis_transaction.reciever == 0
    assert genesis_transaction.amount == 100000
    assert genesis_block.prev == "0000000000000000000000000000000000000000000000000000000000000000"
    assert genesis_block.nonce == 199
    assert genesis_block.hash == "00791D613BDBB5A38021AC84066671925CCA8DA8D361CB1EE98FC718C2E89F2D"
  end

  test "test that the block mined is valid by checking each transaction" do
    pending_transactions = [%{:id => 1},%{:id => 2},%{:id => 3},%{:id => 4},%{:id => 5}]
    assert BitcoinSimulator.is_valid_block([%{:id => 1},%{:id => 2},%{:id => 3},%{:id => 4},%{:id => 5}], pending_transactions)
    assert BitcoinSimulator.is_valid_block([%{:id => 1},%{:id => 3},%{:id => 5}], pending_transactions)
    refute BitcoinSimulator.is_valid_block([%{:id => 3},%{:id => 4},%{:id => 6}], pending_transactions)
  end

  test "test 15 transactions with 100 starting users" do
    io = capture_io(fn -> BitcoinSimulator.main(100, 3) end)
    IO.puts io

    # Receiver verifies the transaction
    assert String.contains?(io, "User 12 verfified transaction of 2 DOSCoins from 11 to 12")

    # Any random user has unchanged wallet
    assert String.contains?(io, "User 110 has 100 DOSCoins in the wallet")

    # Reciever verifies the transaction by the sender is proper
    assert String.contains?(io, "User 12 verfified transaction of 2 DOSCoins from 11 to 12")

    # Miner got 5 DOSCoins as transaction fee
    miner_num = String.split(io, " has added block with 5 transactions successfully") |> Enum.fetch!(0) |> String.split("Miner ") |> Enum.fetch!(1)
    assert String.contains?(io, "Miner " <> miner_num <> " has added block with 5 transactions successfully")
    assert String.contains?(io, "Miner " <> miner_num <> " got 5 DOSCoins!!")

    # Sender's wallet is deducted when the transaction is created
    assert String.contains?(io, "Wallet of sender 11 has 88 DOSCoins")

    # Checking transaction tally for sender and reciever
    assert String.contains?(io, "User 11 has 68 DOSCoins in the wallet") # user 11 sent 32 DOSCoins in 16 transactions. All transactions made are reflected in sender's wallet.
    assert String.contains?(io, "User 12 has 120 DOSCoins in the wallet") # 10 transactions of 2 DOSCoins each are resolved. Only resolved transactions are reflected in reciever's wallet.

    # Checking that the transactions are done
    assert String.contains?(io, "15 transactions and 3 blocks complete")
  end
end
