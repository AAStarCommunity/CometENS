import { Server } from '@chainlink/ccip-read-server';
import { ethers } from 'ethers';
declare type PromiseOrResult<T> = T | Promise<T>;
export interface Database {
    addr(name: string, coinType: number): PromiseOrResult<{
        addr: string;
        ttl: number;
    }>;
    text(name: string, key: string): PromiseOrResult<{
        value: string;
        ttl: number;
    }>;
    contenthash(name: string): PromiseOrResult<{
        contenthash: string;
        ttl: number;
    }>;
}
export declare function makeServer(signer: ethers.utils.SigningKey): Server;
export declare function makeApp(signer: ethers.utils.SigningKey, path: string): any;
export {};
