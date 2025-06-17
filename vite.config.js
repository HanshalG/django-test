import { resolve } from 'path';
import { defineConfig } from 'vite';
import rescript from '@jihchi/vite-plugin-rescript';

export default defineConfig({
  root: './frontend',
  base: '/static/',
  publicDir: '../static',
  build: {
    outDir: '../static/dist',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'frontend/main.js'),
      },
      output: {
        entryFileNames: ['js/[name].js'],
        chunkFileNames: 'js/[name].[hash].js',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name.endsWith('.css')) {
            return 'css/[name][extname]';
          }
          return 'assets/[name][extname]';
        },
      },
    },
  },
  server: {
    port: 3000,
    open: false,
    cors: true,
    // Configure Vite to work with Django's development server
    proxy: {
      '^/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
  plugins: [
    rescript(),
  ],
  resolve: {
    alias: {
      // Add any aliases you need here
    },
  },
});
