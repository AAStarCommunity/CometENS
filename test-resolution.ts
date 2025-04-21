// 测试 ENS 域名解析
import { ethers } from 'ethers';
import * as dotenv from 'dotenv';
import * as fs from 'fs';

// 加载环境变量
dotenv.config();

async function testResolution() {
  // 获取配置
  const ethereumRpcUrl = process.env.ETHEREUM_RPC_URL || 'https://eth-mainnet.g.alchemy.com/v2/your-api-key';
  const rootName = process.env.ENS_ROOT_NAME || 'aastar.eth';
  
  console.log(`Testing resolution for ${rootName}...`);
  console.log(`Using Ethereum RPC: ${ethereumRpcUrl}`);
  
  try {
    // 连接到以太坊主网
    const provider = new ethers.JsonRpcProvider(ethereumRpcUrl);
    
    // 检查域名所有者
    const registryAddress = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e';
    const registryAbi = [
      'function owner(bytes32 node) view returns (address)',
      'function resolver(bytes32 node) view returns (address)'
    ];
    const registry = new ethers.Contract(registryAddress, registryAbi, provider);
    
    // 计算域名的 namehash
    const node = ethers.namehash(rootName);
    console.log(`Domain node: ${node}`);
    
    // 获取域名所有者
    const owner = await registry.owner(node);
    console.log(`Domain owner: ${owner}`);
    
    // 获取域名解析器
    const resolverAddress = await registry.resolver(node);
    console.log(`Domain resolver: ${resolverAddress}`);
    
    // 尝试解析 ENS 名称
    console.log(`\nResolving ${rootName}...`);
    const address = await provider.resolveName(rootName);
    
    if (address) {
      console.log(`Resolution successful! Address: ${address}`);
    } else {
      console.log(`Resolution returned null, but did not throw an error. Check your resolver setup.`);
    }
    
    // 如果部署信息存在，验证 Resolver 地址是否正确
    if (fs.existsSync('./deployments/l1_contracts.env')) {
      const l1Contracts = fs.readFileSync('./deployments/l1_contracts.env', 'utf8');
      const deployedResolverMatch = l1Contracts.match(/OP_RESOLVER_ADDRESS=(.+)/);
      
      if (deployedResolverMatch && deployedResolverMatch[1]) {
        const deployedResolver = deployedResolverMatch[1].trim();
        console.log(`\nDeployed resolver: ${deployedResolver}`);
        
        if (resolverAddress.toLowerCase() === deployedResolver.toLowerCase()) {
          console.log(`✅ Resolver address matches deployed resolver!`);
        } else {
          console.log(`❌ Resolver address does NOT match deployed resolver. Check your setup.`);
        }
      }
    }
    
  } catch (error) {
    console.error('Resolution failed:');
    if (error instanceof Error) {
      console.error(error.message);
      // 打印更详细的错误堆栈
      console.error('\nError stack:');
      console.error(error.stack);
    } else {
      console.error(error);
    }
  }
}

// 运行测试
testResolution().catch(console.error); 