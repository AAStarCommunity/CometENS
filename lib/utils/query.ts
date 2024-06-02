import prisma from "@/lib/db";

export const getAddress = async (node: string) => {
    return await prisma.ens.findUnique({
        where: {
            node: node,
        },
        select: {
            address: true,
        }
    });
}

export const getText = async (node: string) => {
    return await prisma.ens.findUnique({
        where: {
            node: node,
        },
        select: {
            text: true,
        }
    });
}

export const getContenthash = async (node: string) => {
    return await prisma.ens.findUnique({
        where: {
            node: node,
        },
        select: {
            contenthash: true,
        }
    });
}