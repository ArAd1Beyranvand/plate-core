import { fileURLToPath } from 'node:url';

export default { resolve: { preserveSymlinks: true, alias: { 'plate_core/': fileURLToPath(new URL('./src/', import.meta.url)) } } };
