import { useWalletClient, usePublicClient, useEnsResolver, useEnsName } from 'wagmi'
import { namehash, keccak256, toUtf8Bytes, hexlify, Contract, JsonRpcProvider } from 'ethers'
import { useEffect, useState } from 'react'

// ENS注册表合约地址（主网）
const ENS_REGISTRY_ADDRESS = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e'
// 假设使用的Layer2是Optimism，Optimism的ENS解析器地址（需替换为实际地址）
const OPTIMISM_ENS_RESOLVER_ADDRESS = '0xYOUR_OPTIMISM_RESOLVER_ADDRESS'

function ENSDemo() {
  // 获取钱包签名能力（walletClient）和只读provider（publicClient）
  const { data: walletClient } = useWalletClient()
  const { data: publicClient } = usePublicClient()
  const [ensName, setEnsName] = useState('aastar.eth')
  const [subdomain, setSubdomain] = useState('jason.aastar.eth')
  const [address, setAddress] = useState('')
  const [resolverAddress, setResolverAddress] = useState('')

  // ENS解析器
  const { data: resolver } = useEnsResolver({ name: ensName })
  // 反查ENS名
  const { data: resolvedName } = useEnsName({ address: address as `0x${string}` })

  useEffect(() => {
    if (resolver && resolver.address) {
      setResolverAddress(resolver.address)
    }
  }, [resolver])

  // 1. 解析ENS域名到地址
  async function resolveENSName() {
    try {
      if (!publicClient) throw new Error('No publicClient')
      const result = await publicClient.getEnsAddress({ name: ensName })
      if (result) {
        setAddress(result)
        console.log(`域名 ${ensName} 解析到地址: ${result}`)
      } else {
        console.error('无法解析域名')
      }
    } catch (error) {
      console.error('解析ENS域名失败:', error)
    }
  }

  // 2. 注册子域名
  async function registerSubdomain() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      const [account] = walletClient.account ? [walletClient.account.address] : []
      if (!account) throw new Error('No connected account')
      const ensContract = new Contract(
        ENS_REGISTRY_ADDRESS,
        ['function setSubnodeOwner(bytes32 node, bytes32 label, address owner)'],
        walletClient
      )
      const node = namehash(ensName)
      const label = keccak256(toUtf8Bytes(subdomain.split('.')[0]))
      // ethers v6: Contract.connect(walletClient) 直接用walletClient
      const tx = await ensContract.setSubnodeOwner(node, label, account)
      await tx.wait()
      console.log(`子域名 ${subdomain} 注册成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('注册子域名失败:', error)
    }
  }

  // 3. 设置子域名解析地址
  async function setSubdomainResolution() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      const [account] = walletClient.account ? [walletClient.account.address] : []
      if (!account) throw new Error('No connected account')
      if (!resolverAddress) throw new Error('No resolver address')
      const resolverContract = new Contract(
        resolverAddress,
        ['function setAddr(bytes32 node, address addr)'],
        walletClient
      )
      const subdomainNode = namehash(subdomain)
      const tx = await resolverContract.setAddr(subdomainNode, account)
      await tx.wait()
      console.log(`子域名 ${subdomain} 解析地址设置成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('设置子域名解析失败:', error)
    }
  }

  // 4. 在Layer2（如Optimism）上解析子域名
  async function resolveSubdomainOnLayer2() {
    try {
      const optimismProvider = new JsonRpcProvider('[https://mainnet.optimism.io](https://mainnet.optimism.io)')
      const resolverContract = new Contract(
        OPTIMISM_ENS_RESOLVER_ADDRESS,
        ['function addr(bytes32 node) view returns (address)'],
        optimismProvider
      )
      const subdomainNode = namehash(subdomain)
      const resolvedAddress = await resolverContract.addr(subdomainNode)
      console.log(`子域名 ${subdomain} 在Optimism上解析到地址: ${resolvedAddress}`)
    } catch (error) {
      console.error('在Layer2上解析子域名失败:', error)
    }
  }

  // 5. 设置文本记录
  async function setTextRecord() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      if (!resolverAddress) throw new Error('No resolver address')
      const resolverContract = new Contract(
        resolverAddress,
        ['function setText(bytes32 node, string key, string value)'],
        walletClient
      )
      const node = namehash(ensName)
      const tx = await resolverContract.setText(node, 'url', '[https://jason.aastar.io](https://jason.aastar.io)')
      await tx.wait()
      console.log(`文本记录设置成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('设置文本记录失败:', error)
    }
  }

  // 6. 设置Content Hash（用于去中心化网站，如IPFS）
  async function setContentHash() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      if (!resolverAddress) throw new Error('No resolver address')
      const resolverContract = new Contract(
        resolverAddress,
        ['function setContenthash(bytes32 node, bytes hash)'],
        walletClient
      )
      const node = namehash(ensName)
      const ipfsHash = 'QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco'
      const contentHash = hexlify(toUtf8Bytes(`ipfs://${ipfsHash}`))
      const tx = await resolverContract.setContenthash(node, contentHash)
      await tx.wait()
      console.log(`Content Hash 设置成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('设置Content Hash失败:', error)
    }
  }

// 7. 设置ENS头像
async function setAvatar() {
  try {
    if (!walletClient) throw new Error('No walletClient')
    if (!resolverAddress) throw new Error('No resolver address')
    const resolverContract = new Contract(
      resolverAddress,
      ['function setText(bytes32 node, string key, string value)'],
      walletClient
    )
    const node = namehash(ensName)
    // 设置头像（支持URL或NFT，例如OpenSea的NFT链接）
    const avatarUrl = '[https://opensea.io/assets/0x.../123](https://opensea.io/assets/0x.../123)'
    const tx = await resolverContract.setText(node, 'avatar', avatarUrl)
    await tx.wait()
    console.log(`头像设置成功，交易哈希: ${tx.hash}`)
  } catch (error) {
    console.error('设置头像失败:', error)
  }
}

  // 8. 设置合约命名（关联智能合约）
  async function setContractName() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      if (!resolverAddress) throw new Error('No resolver address')
      const resolverContract = new Contract(
        resolverAddress,
        ['function setAddr(bytes32 node, uint coinType, bytes memory a)'],
        walletClient
      )
      const node = namehash(ensName)
      const contractAddress = '0xYourContractAddress'
      const coinType = 60 // 以太坊主网的coinType
      const tx = await resolverContract.setAddr(node, coinType, contractAddress)
      await tx.wait()
      console.log(`合约命名设置成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('设置合约命名失败:', error)
    }
  }

  // 9. 设置多链地址（例如为Bitcoin或Polygon设置地址）
  async function setMultichainAddress() {
    try {
      if (!walletClient) throw new Error('No walletClient')
      if (!resolverAddress) throw new Error('No resolver address')
      const resolverContract = new Contract(
        resolverAddress,
        ['function setAddr(bytes32 node, uint coinType, bytes memory a)'],
        walletClient
      )
      const node = namehash(ensName)
      const bitcoinAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
      const coinType = 0 // Bitcoin的coinType
      const encodedAddress = toUtf8Bytes(bitcoinAddress)
      const tx = await resolverContract.setAddr(node, coinType, encodedAddress)
      await tx.wait()
      console.log(`多链地址（Bitcoin）设置成功，交易哈希: ${tx.hash}`)
    } catch (error) {
      console.error('设置多链地址失败:', error)
    }
  }

  return (
    <div>
      <h1>ENS 域名操作示例</h1>
      <div>
        <label>主域名: </label>
        <input
          value={ensName}
          onChange={(e) => setEnsName(e.target.value)}
          placeholder="aastar.eth"
        />
      </div>
      <div>
        <label>子域名: </label>
        <input
          value={subdomain}
          onChange={(e) => setSubdomain(e.target.value)}
          placeholder="jason.aastar.eth"
        />
      </div>
      <div>
        <button onClick={resolveENSName}>解析ENS域名</button>
        <p>解析地址: {address}</p>
      </div>
      <div>
        <button onClick={registerSubdomain}>注册子域名</button>
      </div>
      <div>
        <button onClick={setSubdomainResolution}>设置子域名解析</button>
      </div>
      <div>
        <button onClick={resolveSubdomainOnLayer2}>在Layer2解析子域名</button>
      </div>
      <div>
        <button onClick={setTextRecord}>设置文本记录</button>
      </div>
      <div>
        <button onClick={setContentHash}>设置Content Hash</button>
      </div>
      <div>
        <button onClick={setAvatar}>设置头像</button>
      </div>
      <div>
        <button onClick={setContractName}>设置合约命名</button>
      </div>
      <div>
        <button onClick={setMultichainAddress}>设置多链地址</button>
      </div>
      <div>
        <p>当前解析器地址: {resolverAddress}</p>
        <p>查询的ENS名称: {resolvedName}</p>
      </div>
    </div>
  )
}

export default ENSDemo