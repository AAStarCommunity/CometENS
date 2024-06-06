export declare function addr(name: string, coinType: number): Promise<{
    addr: string;
    ttl: number;
}>;
export declare function text(name: string, key: string): Promise<{
    value: any;
    ttl: number;
}>;
export declare function contenthash(name: string): Promise<{
    contenthash: any;
    ttl: number;
}>;
