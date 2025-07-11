import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  // Development server configuration
  server: {
    port: 3000,
    host: true, // Allow external connections for Docker
    strictPort: false, // Allow fallback to other ports if 3000 is busy
    hmr: {
      port: 3001,
    },
    // Proxy API requests to backend during development
    proxy: {
      '/api': {
        target: process.env.VITE_API_BASE_URL || 'http://localhost:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },

  // Build configuration
  build: {
    outDir: 'dist',
    sourcemap: true,
    // Optimize for modern browsers
    target: 'es2020',
  },

  // Preview server configuration (for production builds)
  preview: {
    port: 3000,
    host: true,
  },

  // Environment variables
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
  },
});
