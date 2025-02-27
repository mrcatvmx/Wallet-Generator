#!/bin/bash


mkdir -p ~/XXXX
cd ~/XXXX


cat <<EOL > package.json
{
  "name": "xxxx",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@cosmjs/proto-signing": "^0.32.3",
    "@solana/web3.js": "^1.91.8",
    "bip39": "^3.1.0",
    "bs58": "^5.0.0",
    "chalk": "^4.1.2",
    "crypto": "^1.0.1",
    "ethers": "^5.7.2",
    "moment": "^2.30.1",
    "readline-sync": "^1.4.10"
  }
}
EOL


curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install -y nodejs


npm install


cat <<'EOF' > generate_wallets.mjs
import chalk from 'chalk';
import { ethers } from 'ethers';
import { appendFileSync } from 'fs';
import moment from 'moment';
import readlineSync from 'readline-sync';
import { Keypair } from '@solana/web3.js';
import { DirectSecp256k1HdWallet } from '@cosmjs/proto-signing';
import bip39 from 'bip39';
import bs58 from 'bs58';
import crypto from 'crypto';

// Print information and ask for confirmation
console.log(chalk.cyan('════════════════════════════════════════════════════════════'));
console.log(chalk.cyan('║       Welcome to Wallet GENErator BOT!                       ║'));
console.log(chalk.cyan('║                                                              ║'));
console.log(chalk.cyan('║     Follow us on Twitter:                                   ║'));
console.log(chalk.cyan('║     https://twitter.com/cipher_airdrop                      ║'));
console.log(chalk.cyan('║                                                              ║'));
console.log(chalk.cyan('║     Join us on Telegram:                                    ║'));
console.log(chalk.cyan('║     - https://t.me/+tFmYJSANTD81MzE1                       ║'));
console.log(chalk.cyan('╚════════════════════════════════════════════════════════════'));
const answer = readlineSync.question('Will you FC* Airdrops by creating wallets? (Y/N): ');
if (answer.toLowerCase() !== 'y') {
    console.log('Aborting installation.');
    process.exit(1);
}

// Function to create a new EVM (Ethereum) wallet
function createEVMWallet() {
  const wallet = ethers.Wallet.createRandom();
  return {
    address: wallet.address,
    privateKey: wallet.privateKey,
    mnemonic: wallet.mnemonic.phrase,
  };
}

// Function to create a new Solana wallet
function createSolanaWallet() {
  const mnemonic = bip39.generateMnemonic();
  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const seed = crypto.createHash('sha256').update(entropy).digest();
  const keypair = Keypair.fromSeed(seed);
  const privateKey = bs58.encode(keypair.secretKey);

  return {
    address: keypair.publicKey.toBase58(),
    privateKey: privateKey,
    mnemonic: mnemonic,
  };
}

// Function to create a new Cosmos wallet
async function createCosmosWallet() {
  const mnemonic = bip39.generateMnemonic();
  const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic);
  const [{ address }] = await wallet.getAccounts();

  return {
    address: address,
    privateKey: 'N/A (Cosmos uses mnemonics)',
    mnemonic: mnemonic,
  };
}

// Main function using async IIFE (Immediately Invoked Function Expression)
(async () => {
  try {
    // Ask user for the type of chain
    const chainType = readlineSync.question(
      chalk.yellow('Which kind of chain Wallet accounts do you want (EVM, Solana, Cosmos)? ')
    ).toLowerCase();

    // Ask user for the total number of wallets to create
    const totalWallets = parseInt(readlineSync.question(
      chalk.yellow('How many wallets do you want to create? ')
    ), 10);

    if (isNaN(totalWallets) || totalWallets < 1) {
      throw new Error('Invalid number of wallets. Please enter a number > 0.');
    }

    // Initialize an array to hold the wallet details
    const wallets = [];

    // Create the specified number of wallets based on the chain type
    for (let i = 0; i < totalWallets; i++) {
      let wallet;
      switch (chainType) {
        case 'evm':
          wallet = createEVMWallet();
          break;
        case 'solana':
          wallet = createSolanaWallet();
          break;
        case 'cosmos':
          wallet = await createCosmosWallet();
          break;
        default:
          console.log(chalk.red('Invalid chain type.'));
          return;
      }

      wallets.push(wallet);
      console.log(
        chalk.green(
          `[${moment().format('HH:mm:ss')}] Wallet created! Address: ${wallet.address}`
        )
      );

      // Append wallet details to result.txt
      appendFileSync(
        './result.txt',
        `Address: ${wallet.address} | Private Key: ${wallet.privateKey} | Mnemonic: ${wallet.mnemonic}\n`
      );
    }

    console.log(
      chalk.green('All wallets have been created. Check result.txt to see the details.')
    );
  } catch (error) {
    console.error('An error occurred:'.red, error.message);
  }
})();
EOF


node generate_wallets.mjs
