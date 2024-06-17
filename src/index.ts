import { makeApp } from './server';
import { ethers } from 'ethers';

let privateKey = process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const port = 8080

const address = ethers.utils.computeAddress(privateKey);
const signer = new ethers.utils.SigningKey(privateKey);
const app = makeApp(signer, '/');
console.log(`Serving on port ${port} with signing address ${address}`);
app.listen(port);
