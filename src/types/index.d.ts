import type { Telegram } from './telegram';

namespace globalThis {
  export interface Window {
    Telegram: Telegram;
  }
}
