#here we will define some shortcuts to make things a bit easier
-include .env  # this will read all the variables from env file

build:; forge build   # (;) is used to write command on same line

delpoy-seoplia:
	forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --legacy -vvvv  
#in above line --verify --etherscan-api-key $(ETHERSCAN_API_KEY) will automatically verify the contract with etherscan.




