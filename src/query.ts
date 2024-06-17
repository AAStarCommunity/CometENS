import prisma from "./db";

export const getAddress = async (node: string) => {
  return await prisma.ens.findUnique({
    // @ts-ignore
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
    // @ts-ignore
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
    // @ts-ignore
    where: {
      node: node,
    },
    select: {
      contenthash: true,
    }
  });
}