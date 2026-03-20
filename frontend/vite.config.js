import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

const backendProxyTarget = process.env.BACKEND_PROXY_TARGET || 'http://localhost:8000';
const backendWsTarget = backendProxyTarget.replace(/^http/i, 'ws');

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react({
      // Enable Fast Refresh
      fastRefresh: true,
      // Babel plugins
      babel: {
        plugins: [
          // Add any babel plugins here if needed
        ],
      },
    }),
  ],

  // Path aliases
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@context': path.resolve(__dirname, './src/context'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@assets': path.resolve(__dirname, './src/assets'),
    },
  },

  // Development server configuration
  server: {
    port: 3000,
    host: true, // Listen on all addresses
    open: true, // Auto open browser
    strictPort: false, // Try next port if 3000 is busy
    
    // CORS configuration
    cors: true,

    // Proxy configuration for API calls
    proxy: {
      '/api': {
        target: backendProxyTarget,
        changeOrigin: true,
        secure: false,
        // Don't rewrite path - backend also uses /api prefix
        // Configure headers if needed
        configure: (proxy, options) => {
          proxy.on('error', (err, _req, _res) => {
            console.log('proxy error', err);
          });
          proxy.on('proxyReq', (proxyReq, req, _res) => {
            console.log('Sending Request to the Target:', req.method, req.url);
          });
          proxy.on('proxyRes', (proxyRes, req, _res) => {
            console.log('Received Response from the Target:', proxyRes.statusCode, req.url);
          });
        },
      },
      '/uploads': {
        target: backendProxyTarget,
        changeOrigin: true,
        secure: false,
      },
      // WebSocket proxy for real-time features
      '/ws': {
        target: backendWsTarget,
        ws: true,
        changeOrigin: true,
      },
    },

    // HMR configuration
    hmr: {
      overlay: true, // Show error overlay
    },

    // Watch options
    watch: {
      usePolling: true, // Enable if needed for Docker/WSL
      interval: 1000,
    },
  },

  // Preview server configuration (for production build preview)
  preview: {
    port: 4173,
    host: true,
    strictPort: false,
    open: true,
  },

  // Build configuration
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true, // Generate source maps for debugging
    
    // Minification
    minify: 'esbuild', // 'esbuild' (faster) or 'terser' (better compression)
    
    // Target browsers
    target: 'esnext',
    
    // Chunk size warnings
    chunkSizeWarningLimit: 1000, // KB
    
    // Rollup options
    rollupOptions: {
      output: {
        // Manual chunks for better code splitting
        manualChunks: {
          // React core
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          
          // UI libraries
          'ui-vendor': ['lucide-react'],
          
          // HTTP client
          'http-vendor': ['axios'],
        },
        
        // Asset file names
        assetFileNames: (assetInfo) => {
          let extType = assetInfo.name.split('.').pop();
          if (/png|jpe?g|svg|gif|tiff|bmp|ico/i.test(extType)) {
            extType = 'images';
          } else if (/woff|woff2|eot|ttf|otf/i.test(extType)) {
            extType = 'fonts';
          }
          return `assets/${extType}/[name]-[hash][extname]`;
        },
        
        // Chunk file names
        chunkFileNames: 'assets/js/[name]-[hash].js',
        
        // Entry file names
        entryFileNames: 'assets/js/[name]-[hash].js',
      },
    },

    // CSS code splitting
    cssCodeSplit: true,
    
    // Report compressed size
    reportCompressedSize: true,
    
    // Clear output directory before build
    emptyOutDir: true,
  },

  // CSS configuration
  css: {
    // CSS modules configuration
    modules: {
      localsConvention: 'camelCase',
    },
    
    // CSS preprocessor options
    preprocessorOptions: {
      scss: {
        additionalData: `@import "@/styles/variables.scss";`,
      },
    },
    
    // PostCSS configuration (optional)
    postcss: {
      plugins: [
        // Add PostCSS plugins here if needed
      ],
    },
  },

  // Optimization
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-router-dom',
      'axios',
      'lucide-react',
    ],
    exclude: ['@vite/client', '@vite/env'],
  },

  // Environment variables prefix
  envPrefix: 'VITE_',

  // Define global constants
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
  },

  // Dependency optimization
  esbuild: {
    logOverride: { 'this-is-undefined-in-esm': 'silent' },
    jsxInject: `import React from 'react'`, // Auto-inject React for JSX
  },

  // Performance
  performance: {
    maxAssetSize: 1000000, // 1MB in bytes
    maxEntrypointSize: 1000000,
  },
});