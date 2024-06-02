-- CreateTable
CREATE TABLE "Ens" (
    "id" SERIAL NOT NULL,
    "node" TEXT NOT NULL,
    "address" JSONB NOT NULL,
    "text" JSONB NOT NULL,
    "contenthash" TEXT NOT NULL,

    CONSTRAINT "Ens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Ens_node_key" ON "Ens"("node");
