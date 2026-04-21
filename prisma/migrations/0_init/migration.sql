-- CreateEnum: TikTokPostStatus
DO $$ BEGIN
    CREATE TYPE "TikTokPostStatus" AS ENUM ('PENDING', 'SENT', 'FAILED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- CreateTikTokPost
CREATE TABLE "TikTokPost" (
    "id" TEXT NOT NULL,
    "messageId" TEXT NOT NULL,
    "recipient" TEXT NOT NULL,
    "caption" TEXT NOT NULL,
    "videoUrl" TEXT NOT NULL,
    "coverUrl" TEXT,
    "status" "TikTokPostStatus" NOT NULL DEFAULT 'PENDING',
    "publishId" TEXT,
    "errorReason" TEXT,
    "sentAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "TikTokPost_pkey" PRIMARY KEY ("id")
);