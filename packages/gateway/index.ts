import { createPublicClient, http, decodeFunctionData, encodeFunctionResult } from 'viem';
import { optimismSepolia } from 'viem/chains';
const AddrResolverAbi = [
  {
    type: 'function',
    name: 'addr',
    stateMutability: 'view',
    inputs: [{ name: 'node', type: 'bytes32' }],
    outputs: [{ name: '', type: 'address' }],
  },
] as const;

class NameWrapperDataSource {
    provider: any;
    nameWrapperAddress: `0x${string}`;

    constructor(l2RpcUrl: string, nameWrapperAddress: `0x${string}`) {
        this.provider = createPublicClient({
            chain: optimismSepolia,
            transport: http(l2RpcUrl),
        });
        this.nameWrapperAddress = nameWrapperAddress;
    }

    async handleRead(calldata: string): Promise<string> {
        const decoded = decodeFunctionData({
          abi: AddrResolverAbi,
          data: calldata as `0x${string}`,
        });
        if (decoded.functionName === 'addr') {
          const [node] = decoded.args as [`0x${string}`];
          const result = await this.provider.readContract({
            address: this.nameWrapperAddress,
            abi: AddrResolverAbi,
            functionName: 'addr',
            args: [node],
          });
          return encodeFunctionResult({
            abi: AddrResolverAbi,
            functionName: 'addr',
            result: [result],
          });
        }
        throw new Error(`Unsupported method: ${decoded.functionName}`);
    }
}

console.log('Starting CometENS Standalone Gateway...');

const ALCHEMY_KEY = process.env.ALCHEMY_KEY;
if (!ALCHEMY_KEY) {
    throw new Error("ALCHEMY_KEY environment variable is not set.");
}

const l2RpcUrl = `https://opt-sepolia.g.alchemy.com/v2/${ALCHEMY_KEY}`;
const nameWrapperAddress = '0x42d63ae25990886eA35F27a553440E2946209422';

const dataSource = new NameWrapperDataSource(l2RpcUrl, nameWrapperAddress);
const port = 8000;

Bun.serve({
    port,
    async fetch(req) {
        if (req.method !== 'POST') return new Response('Unsupported method', { status: 405 });
        try {
            const { data: calldata } = await req.json();
            const data = await dataSource.handleRead(calldata);
            return Response.json({ data }, { headers: { 'Access-Control-Allow-Origin': '*' } });
        } catch (e: any) {
            return Response.json({ error: e.message }, { status: 500 });
        }
    },
});

console.log(`CometENS Gateway listening on port ${port}`);
