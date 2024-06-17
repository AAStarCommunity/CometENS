import { getAddress, getText, getContenthash } from './query';

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const EMPTY_CONTENT_HASH = '0x';
const ttl = 300;

export async function addr(name: string, coinType: number) {
  try {
    let addresses = await getAddress(name);
    // @ts-ignore
    addresses = addresses?.address;
    let addr = ZERO_ADDRESS;
    // @ts-ignore
    if (addresses && addresses[coinType]) {
      // @ts-ignore
      addr = '' + addresses[coinType];
    }
    return { addr, ttl };

  } catch (e) {
    return { addr: ZERO_ADDRESS, ttl };
  }
}

export async function text(name: string, key: string) {
  try {
    const texts = await getText(name);
    // @ts-ignore
    const text = texts?.text;

    // @ts-ignore
    if (text && text[key]) {   // @ts-ignore
      return { value: text[key], ttl };
    } else {
      return { value: '', ttl };
    }
  } catch (e) {
    return { value: '', ttl };
  }
}

export async function contenthash(name: string) {
  try {
    const contenthashRes = await getContenthash(name);
    // @ts-ignore
    const contenthash = contenthashRes?.contenthash;

    if (contenthash) {
      return { contenthash: contenthash, ttl };
    } else {
      return { contenthash: EMPTY_CONTENT_HASH, ttl };
    }
  } catch (e) {
    return { contenthash: EMPTY_CONTENT_HASH, ttl };
  }
}

// ~(async function () {
// const address = await getAddress('ethpaymaster.eth');
// const address1 = await addr('ethpaymaster.eth', 60);
// console.log(address, address1, 'address 11');
// }())