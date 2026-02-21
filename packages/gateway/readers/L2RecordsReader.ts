import { Address, PublicClient, decodeFunctionResult, encodeFunctionData } from 'viem'

const RecordsAbi = [
  {
    type: 'function',
    name: 'addr',
    stateMutability: 'view',
    inputs: [{ name: 'node', type: 'bytes32' }],
    outputs: [{ name: '', type: 'address' }],
  },
  {
    type: 'function',
    name: 'text',
    stateMutability: 'view',
    inputs: [
      { name: 'node', type: 'bytes32' },
      { name: 'key', type: 'string' },
    ],
    outputs: [{ name: '', type: 'string' }],
  },
  {
    type: 'function',
    name: 'contenthash',
    stateMutability: 'view',
    inputs: [{ name: 'node', type: 'bytes32' }],
    outputs: [{ name: '', type: 'bytes' }],
  },
] as const

export class L2RecordsReader {
  private client: PublicClient
  private address: Address

  constructor(client: PublicClient, address: Address) {
    this.client = client
    this.address = address
  }

  async read(calldata: `0x${string}`): Promise<`0x${string}`> {
    const selector = calldata.slice(0, 10)
    if (selector === '0x3b3b57de') {
      const result = await this.client.call({
        to: this.address,
        data: calldata,
      })
      const decoded = decodeFunctionResult({
        abi: RecordsAbi,
        functionName: 'addr',
        data: result.data as `0x${string}`,
      })
      return encodeFunctionData({
        abi: RecordsAbi,
        functionName: 'addr',
        args: [decoded as Address],
      })
    }
    if (selector === '0x59d1d43c') {
      const result = await this.client.call({
        to: this.address,
        data: calldata,
      })
      const decoded = decodeFunctionResult({
        abi: RecordsAbi,
        functionName: 'text',
        data: result.data as `0x${string}`,
      })
      return encodeFunctionData({
        abi: RecordsAbi,
        functionName: 'text',
        args: [decoded as string],
      })
    }
    if (selector === '0xbc1c58d1') {
      const result = await this.client.call({
        to: this.address,
        data: calldata,
      })
      const decoded = decodeFunctionResult({
        abi: RecordsAbi,
        functionName: 'contenthash',
        data: result.data as `0x${string}`,
      })
      return encodeFunctionData({
        abi: RecordsAbi,
        functionName: 'contenthash',
        args: [decoded as `0x${string}`],
      })
    }
    throw new Error('unsupported selector')
  }
}
