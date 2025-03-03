import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can mint new NFT with expiration",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("timesnap", "mint",
        [types.uint(1), types.principal(wallet1.address), types.uint(100), types.utf8("ipfs://test")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, '(ok true)');
    
    // Verify last token ID
    block = chain.mineBlock([
      Tx.contractCall("timesnap", "get-last-token-id", [], deployer.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok u1)');
  },
});

Clarinet.test({
  name: "Ensure cannot mint duplicate token ID",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("timesnap", "mint",
        [types.uint(1), types.principal(wallet1.address), types.uint(100), types.utf8("ipfs://test")],
        deployer.address
      ),
      Tx.contractCall("timesnap", "mint",
        [types.uint(1), types.principal(wallet1.address), types.uint(100), types.utf8("ipfs://test")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts[1].result, `${types.err(105)}`);
  },
});

Clarinet.test({
  name: "Ensure cannot mint with invalid duration",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("timesnap", "mint",
        [types.uint(1), types.principal(wallet1.address), types.uint(0), types.utf8("ipfs://test")],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, `${types.err(106)}`);
  },
});

Clarinet.test({
  name: "Ensure can burn expired NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("timesnap", "mint",
        [types.uint(1), types.principal(wallet1.address), types.uint(10), types.utf8("ipfs://test")],
        deployer.address
      )
    ]);

    chain.mineEmptyBlockUntil(20);

    block = chain.mineBlock([
      Tx.contractCall("timesnap", "burn",
        [types.uint(1)],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, '(ok true)');
  },
});
