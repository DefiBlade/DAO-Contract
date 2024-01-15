# Token and Dao contract Test

When testing your DAO token and Governor token contracts, it's important to cover all of the key functionality of these contracts. Here are some functions that you should consider testing:

## For the DAO token contract:

Token transfers: Test the ability to transfer tokens between accounts, as well as functionality such as approving token transfers and transferring tokens on behalf of other accounts.

Token ownership: Test the ability to check token ownership and balance of accounts, as well as the ability to transfer ownership of tokens.

Token burning: Test the ability to burn tokens, if applicable.

Token minting: Test the ability to mint tokens, if applicable.

Token locking: Test the ability to lock tokens for a specified period of time, if applicable.

## For the Governor token contract:

Proposal creation: Test the ability to create new proposals for governance decisions, including setting parameters and specifying actions to be taken.

Proposal voting: Test the ability to vote on proposals, including both standard voting and delegated voting.

Proposal execution: Test the ability to execute approved proposals and carry out specified actions.

Quorum calculation: Test the calculation of quorum for proposals, including the number of votes required to approve a proposal.

Proposal cancellation: Test the ability to cancel proposals that have not yet been executed.

Time-based constraints: Test any time-based constraints on proposals, such as minimum voting periods or time limits for proposal execution.

Overall, when testing your DAO and Governor token contracts, it's important to ensure that you cover all of the key functionality of these contracts, including both basic transactions and more complex governance decisions. By testing these functions thoroughly, you can help ensure that your contracts are robust, secure, and ready for deployment.




# propose sample

0	targets	address[]	0x8D4785F7ad1021dFF8eAb05D955fDC049e43CaA8
1	values	uint256[]	0
2	signatures	string[]	transfer(address,uint256)
3	calldatas	bytes[]	0x0000000000000000000000001f0686d51e9807b08a2f3d9be8cb5c2f770871de0000000000000000000000000000000000000000000000056bc75e2d63100000

send 100 tokens to 0x1f0686d51e9807b08a2f3d9be8cb5c2f770871de 


Innovative Dao Proposal1. This proposal is test proposal which sending 100 tokens to target address.

