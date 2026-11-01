import { defineConfig } from 'vite';

export default defineConfig({
  root: import.meta.dirname,
  base: './',
  logLevel: 'warn',
  build: { outDir: 'dist', emptyOutDir: true, target: 'es2022' },
});
