import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "permission.updated") {
        await Bun.write(Bun.stdout, "\x07");
        await $`afplay ~/Documents/notification.wav`;
      }
      if (event.type === "session.idle") {
        await Bun.write(Bun.stdout, "\x07");
        await $`afplay ~/Documents/celebration.wav`;
      }
    },
  };
};