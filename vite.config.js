import { resolve } from 'path';

export default {
  root: './frontend', // tell Vite to look in the frontend directory
  base: '/static/',   // where the built files will be served from in Django
  build: {
    outDir: '../static/',  // output to Django's static folder
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'frontend/main.js'),  // your true entrypoint
      },
      output: {
        entryFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name][extname]',
      },
    },
  },
};
