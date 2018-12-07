# Bitcoin

## Group members

* Prahlad Misra [UFID: 00489999]
* Saranya Vatti [UFID: 29842706]

## Instructions

* Project was developed and tested in windows 8; 4 core
* Unzip prahlad_saranya.zip 

```sh
> unzip prahlad_saranya.zip
> cd prahlad_saranya
> mix test
```

## The implementation

* The supervisor starts 10 miner processes and 2 user processes and makes a genesis transaction of 100000 DOSCoins
* Each miner starts with miner_num, 0 amount, empty blockchain and empty list of pending transactions
* Each user starts with user_num, 0 amount, private key, public key, empty blockchain
* Every user and miner are connected (they have all the pids)
* As soon as the miners are spawned, they start mining. That is, they fetch the list of pending transactions from supervisor and take the first 5 transactions; create block; add their miner_num; add a number nonce and try to create a hash such that it starts with two zeroes
* After miner succesfully mines a block (finds a hash that starts with two zeroes), it sends a request to supervisor to add the block to the chain.
* The first miner to add to the chain is said to validate the transactions within the block.
* After the miner has added a block successfully to the blockchain, all the transactions within the block are resolved (recievers get their amount), and the miner gets a commission fee of 5 DOSCoins
* If the block is invalid, the sender gets the money back and the reciever does not get any amount and the transaction is invalidated
* Once the miner is done mining the previous block, it requests the supervisor again for any pending transactions
* Users can make a transaction at any time. The transaction has a sender id, reciever id, the amount and the timestamp for uniqueness
* A sender creates a transaction and requests the receiver to validate it
* Once the reciever validates the transaction, it publishes the transaction to the supervisor
* The supervisor adds the transaction to the list of pending transactions which is then mined by the next free miner

## Additional Bitcoin features implemented

* The miner gets a transaction fee of 5 DOSCoins

## Tests

### Command

```sh
> mix test
....Wallet created with 100 DOSCoins for user 11
Wallet created with 100 DOSCoins for user 12
Wallet created with 100 DOSCoins for user 13
Wallet created with 100 DOSCoins for user 14
Wallet created with 100 DOSCoins for user 15
Wallet created with 100 DOSCoins for user 16
Wallet created with 100 DOSCoins for user 17
Wallet created with 100 DOSCoins for user 18
Wallet created with 100 DOSCoins for user 19
Wallet created with 100 DOSCoins for user 20
Wallet created with 100 DOSCoins for user 21
Wallet created with 100 DOSCoins for user 22
Wallet created with 100 DOSCoins for user 23
Wallet created with 100 DOSCoins for user 24
Wallet created with 100 DOSCoins for user 25
Wallet created with 100 DOSCoins for user 26
Wallet created with 100 DOSCoins for user 27
Wallet created with 100 DOSCoins for user 28
Wallet created with 100 DOSCoins for user 29
Wallet created with 100 DOSCoins for user 30
Wallet created with 100 DOSCoins for user 31
Wallet created with 100 DOSCoins for user 32
Wallet created with 100 DOSCoins for user 33
Wallet created with 100 DOSCoins for user 34
Wallet created with 100 DOSCoins for user 35
Wallet created with 100 DOSCoins for user 36
Wallet created with 100 DOSCoins for user 37
Wallet created with 100 DOSCoins for user 38
Wallet created with 100 DOSCoins for user 39
Wallet created with 100 DOSCoins for user 40
Wallet created with 100 DOSCoins for user 41
Wallet created with 100 DOSCoins for user 42
Wallet created with 100 DOSCoins for user 43
Wallet created with 100 DOSCoins for user 44
Wallet created with 100 DOSCoins for user 45
Wallet created with 100 DOSCoins for user 46
Wallet created with 100 DOSCoins for user 47
Wallet created with 100 DOSCoins for user 48
Wallet created with 100 DOSCoins for user 49
Wallet created with 100 DOSCoins for user 50
Wallet created with 100 DOSCoins for user 51
Wallet created with 100 DOSCoins for user 52
Wallet created with 100 DOSCoins for user 53
Wallet created with 100 DOSCoins for user 54
Wallet created with 100 DOSCoins for user 55
Wallet created with 100 DOSCoins for user 56
Wallet created with 100 DOSCoins for user 57
Wallet created with 100 DOSCoins for user 58
Wallet created with 100 DOSCoins for user 59
Wallet created with 100 DOSCoins for user 60
Wallet created with 100 DOSCoins for user 61
Wallet created with 100 DOSCoins for user 62
Wallet created with 100 DOSCoins for user 63
Wallet created with 100 DOSCoins for user 64
Wallet created with 100 DOSCoins for user 65
Wallet created with 100 DOSCoins for user 66
Wallet created with 100 DOSCoins for user 67
Wallet created with 100 DOSCoins for user 68
Wallet created with 100 DOSCoins for user 69
Wallet created with 100 DOSCoins for user 70
Wallet created with 100 DOSCoins for user 71
Wallet created with 100 DOSCoins for user 72
Wallet created with 100 DOSCoins for user 73
Wallet created with 100 DOSCoins for user 74
Wallet created with 100 DOSCoins for user 75
Wallet created with 100 DOSCoins for user 76
Wallet created with 100 DOSCoins for user 77
Wallet created with 100 DOSCoins for user 78
Wallet created with 100 DOSCoins for user 79
Wallet created with 100 DOSCoins for user 80
Wallet created with 100 DOSCoins for user 81
Wallet created with 100 DOSCoins for user 82
Wallet created with 100 DOSCoins for user 83
Wallet created with 100 DOSCoins for user 84
Wallet created with 100 DOSCoins for user 85
Wallet created with 100 DOSCoins for user 86
Wallet created with 100 DOSCoins for user 87
Wallet created with 100 DOSCoins for user 88
Wallet created with 100 DOSCoins for user 89
Wallet created with 100 DOSCoins for user 90
Wallet created with 100 DOSCoins for user 91
Wallet created with 100 DOSCoins for user 92
Wallet created with 100 DOSCoins for user 93
Wallet created with 100 DOSCoins for user 94
Wallet created with 100 DOSCoins for user 95
Wallet created with 100 DOSCoins for user 96
Wallet created with 100 DOSCoins for user 97
Wallet created with 100 DOSCoins for user 98
Wallet created with 100 DOSCoins for user 99
Wallet created with 100 DOSCoins for user 100
Wallet created with 100 DOSCoins for user 101
Wallet created with 100 DOSCoins for user 102
Wallet created with 100 DOSCoins for user 103
Wallet created with 100 DOSCoins for user 104
Wallet created with 100 DOSCoins for user 105
Wallet created with 100 DOSCoins for user 106
Wallet created with 100 DOSCoins for user 107
Wallet created with 100 DOSCoins for user 108
Wallet created with 100 DOSCoins for user 109
Wallet created with 100 DOSCoins for user 110
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 98 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 96 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 94 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 92 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 90 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 88 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Miner 4 has added block with 5 transactions successfully
Wallet of sender 11 has 86 DOSCoins
Miner 4 got 5 DOSCoins!!
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 84 DOSCoins
Wallet of reciever 12 has 102 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of reciever 12 has 104 DOSCoins
Wallet of sender 11 has 82 DOSCoins
Wallet of reciever 12 has 106 DOSCoins
Wallet of reciever 12 has 108 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of reciever 12 has 110 DOSCoins
Wallet of sender 11 has 80 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Miner 1 has added block with 5 transactions successfully
Wallet of sender 11 has 78 DOSCoins
Miner 1 got 5 DOSCoins!!
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 76 DOSCoins
Wallet of reciever 12 has 112 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 74 DOSCoins
Wallet of reciever 12 has 114 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of reciever 12 has 116 DOSCoins
Wallet of sender 11 has 72 DOSCoins
Wallet of reciever 12 has 118 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 70 DOSCoins
Wallet of reciever 12 has 120 DOSCoins
User 12 verfified transaction of 2 DOSCoins from 11 to 12
Wallet of sender 11 has 68 DOSCoins
15 transactions and 3 blocks complete
pending transactions: []
blockchain: [%{block_num: 0, data: [%{amount: 100000, id: 0, reciever: 0, sender: 0}], hash: "00791D613BDBB5A38021AC84066671925CCA8DA8D361CB1EE98FC718C2E89F2D", nonce: 199, prev: "0000000000000000000000000000000000000000000000000000000000000000"}, %{block_num: 1, data: [%{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}], hash: "00A2E68081EB7C33A6F0A90799FFB4F3C9D1676A7E6E0C54C582AC9E7E6CAFD8", miner_num: 4, nonce: 89, prev: "00791D613BDBB5A38021AC84066671925CCA8DA8D361CB1EE98FC718C2E89F2D"}, %{block_num: 1, data: [%{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}, %{amount: 2, id: "1543881557864:11 sends 2 DOSCoins to 12", reciever: 12, sender: 11}], hash: "00C1ABA90E0C69E11507FDFFF2A3E4B966665D7145D2B10B316AA33D16C4DBF2", miner_num: 1, nonce: 63, prev: "00791D613BDBB5A38021AC84066671925CCA8DA8D361CB1EE98FC718C2E89F2D"}]
.

Finished in 0.2 seconds
5 tests, 0 failures

Randomized with seed 604000
```

## Test descriptions

### test the function that creates nonce and hash in the simulator
### test the function that creates nonce and hash in each miner

* Tests that the hash is created correctly for a given string
* Tests that the number is also added properly while mining so that the hash starts with two zeroes

### test the genesis transaction

* tests that the genesis transaction is created with the correct id, amount and other parameters
* tests that the genesis block is created in the blockchain

### test that the block mined is valid by checking each transaction

* unit test case - checks the functionality of mined block
* if a miner has previously mined the same transaction in a different block, the transaction will not be in the mempool
* if any transaction from the block is not in mempool, it is not valid

### test 15 transactions with 100 starting users

* The supervisor starts 10 miner processes and 100 user processes and makes a genesis transaction of 100000 DOSCoins
* Of all the user processes, process with user_num 11 is a sender while process with user_num 12 is a reciever
* There are 15 transactions where user 11 sends 2 DOSCoins to user 12 in each transaction
* These are chopped off into blocks and hashed by the lucky miners
* Any three lucky miners get the 5 DOSCoins each
* Every action is printed to the output as it happens
* The blockchain at the end is printed
* Any pending_transactions list is also printed for convenience
* Hashes can be tested by looking at the "hash" value in each "block" in the blockchain. Each of these start with two zeroes
* Wallet is checked by looking at the amount of DOSCoins in sender and reciever at every point
* Bitcoin is transacted as per each verified transaction 
* Each step of the simulation is logged to IO and this log is checked in the test case
