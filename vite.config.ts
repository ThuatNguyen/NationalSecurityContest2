import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import runtimeErrorOverlay from "@replit/vite-plugin-runtime-error-modal";

export default defineConfig({
  plugins: [
    react(),
    runtimeErrorOverlay(),
    ...(process.env.NODE_ENV !== "production" &&
    process.env.REPL_ID !== undefined
      ? [
          await import("@replit/vite-plugin-cartographer").then((m) =>
            m.cartographer(),
          ),
          await import("@replit/vite-plugin-dev-banner").then((m) =>
            m.devBanner(),
          ),
        ]
      : []),
  ],
  resolve: {
    alias: {
      "@": path.resolve(import.meta.dirname, "client", "src"),
      "@shared": path.resolve(import.meta.dirname, "shared"),
      "@assets": path.resolve(import.meta.dirname, "attached_assets"),
    },
  },
  root: path.resolve(import.meta.dirname, "client"),
  build: {
    outDir: path.resolve(import.meta.dirname, "dist/public"),
    emptyOutDir: true,
    target: 'es2020',
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          // React core
          'react-vendor': ['react', 'react-dom', 'react/jsx-runtime'],
          // Router
          'router': ['wouter'],
          // React Query
          'query': ['@tanstack/react-query'],
          // UI components - split into smaller chunks
          'ui-core': [
            '@/components/ui/button',
            '@/components/ui/card',
            '@/components/ui/input',
            '@/components/ui/label',
            '@/components/ui/select',
            '@/components/ui/dialog',
            '@/components/ui/dropdown-menu',
          ],
          'ui-extended': [
            '@/components/ui/table',
            '@/components/ui/tooltip',
            '@/components/ui/tabs',
            '@/components/ui/progress',
            '@/components/ui/checkbox',
            '@/components/ui/alert',
          ],
          // Icons
          'icons': ['lucide-react'],
          // Excel export
          'excel': ['exceljs'],
        },
      },
    },
    chunkSizeWarningLimit: 600, // Increase limit to 600kb
  },
  server: {
    host: "0.0.0.0",
    port: 5173,
    strictPort: false,
    hmr: {
      clientPort: 443,
      protocol: 'wss',
    },
    fs: {
      strict: true,
      deny: ["**/.*"],
    },
  },
});
