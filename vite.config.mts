import { defineConfig } from "vite";
import { compiler, stripGXTDebug } from "@lifeart/gxt/compiler";
import babel from "vite-plugin-babel";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig(({ mode }) => ({
  plugins: [
    mode === "production"
      ? (babel({
          babelConfig: {
            babelrc: false,
            configFile: false,
            plugins: [stripGXTDebug],
          },
        }) as any)
      : null,
    compiler(mode),
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: [
        "favicon.ico",
        "android-chrome-192x192.png",
        "android-chrome-512x512.png",
        "apple-touch-icon.png",
        "favicon-32x32.png",
        "favicon-16x16.png",
      ],
      manifest: {
        name: "2048",
        short_name: "2048",
        icons: [
          {
            src: "./android-chrome-192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "./android-chrome-512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
        ],
        theme_color: "#ffffff",
        background_color: "#ffffff",
        display: "standalone",
      },
    }),
  ],
  base: "",
  rollupOptions: {
    input: {
      main: "index.html",
      tests: "tests.html",
    },
  },
  resolve: {
    alias: [{ find: /^@\/(.+)/, replacement: "/src/$1" }],
  },
}));
