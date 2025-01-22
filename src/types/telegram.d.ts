declare namespace Telegram {
  interface EventHandlers {
    [eventType: string]: Function[];
  }

  interface InitParams {
    tgWebAppData?: string;
    tgWebAppThemeParams?: string;
    tgWebAppVersion?: string;
    tgWebAppPlatform?: string;
    tgWebAppDebug?: boolean;
    tgWebAppShowSettings?: boolean;
    tgWebAppBotInline?: boolean;
  }

  interface ThemeParams {
    bg_color?: string; // Optional. Background color in the #RRGGBB format.
    text_color?: string; // Optional. Main text color in the #RRGGBB format.
    hint_color?: string; // Optional. Hint text color in the #RRGGBB format.
    link_color?: string; // Optional. Link color in the #RRGGBB format.
    button_color?: string; // Optional. Button color in the #RRGGBB format.
    button_text_color?: string; // Optional. Button text color in the #RRGGBB format.
    secondary_bg_color?: string; // Optional. Bot API 6.1+ Secondary background color in the #RRGGBB format.
    header_bg_color?: string; // Optional. Bot API 7.0+ Header background color in the #RRGGBB format.
    accent_text_color?: string; // Optional. Bot API 7.0+ Accent text color in the #RRGGBB format.
    section_bg_color?: string; // Optional. Bot API 7.0+ Background color for the section in the #RRGGBB format. It is recommended to use this in conjunction with secondary_bg_color.
    section_header_text_color?: string; // Optional. Bot API 7.0+ Header text color for the section in the #RRGGBB format.
    section_separator_color?: string; // Optional. Bot API 7.6+ Section separator color in the #RRGGBB format.
    subtitle_text_color?: string; // Optional. Bot API 7.0+ Subtitle text color in the #RRGGBB format.
    destructive_text_color?: string; // Optional. Bot API 7.0+ Text color for destructive actions in the #RRGGBB format.
  }

  interface PopupButton {
    id?: string;
    type: 'default' | 'destructive' | 'ok' | 'close' | 'cancel';
    text?: string;
  }

  interface PopupParams {
    title?: string;
    message: string;
    buttons?: PopupButton[];
  }

  interface WebAppUser {
    id: number; // A unique identifier for the user or bot.
    is_bot?: boolean; // Optional. True, if this user is a bot. Returns in the receiver field only.
    first_name: string; // First name of the user or bot.
    last_name?: string; // Optional. Last name of the user or bot.
    username?: string; // Optional. Username of the user or bot.
    language_code?: string; // Optional. IETF language tag of the user's language. Returns in user field only.
    is_premium?: boolean; // Optional. True, if this user is a Telegram Premium user.
    added_to_attachment_menu?: boolean; // Optional. True, if this user added the bot to the attachment menu.
    allows_write_to_pm?: boolean; // Optional. True, if this user allowed the bot to message them.
    photo_url?: string; // Optional. URL of the user’s profile photo. The photo can be in .jpeg or .svg formats. Only returned for Mini Apps launched from the attachment menu.
  }

  interface WebAppChat {
    id: number;
    type: 'private' | 'group' | 'supergroup' | 'channel';
    title?: string;
    username?: string;
    photo_url?: string;
  }

  interface WebAppInitDataUnsafe {
    query_id?: string; // Optional. A unique identifier for the Mini App session.
    user?: WebAppUser; // Optional. An object containing data about the current user.
    receiver?: WebAppUser; // Optional. An object containing data about the chat partner of the current user in the chat where the bot was launched via the attachment menu.
    chat?: WebAppChat; // Optional. An object containing data about the chat where the bot was launched via the attachment menu.
    chat_type?: string; // Optional. Type of the chat from which the Mini App was opened.
    chat_instance?: string; // Optional. Global identifier, uniquely corresponding to the chat from which the Mini App was opened.
    start_param?: string; // Optional. The value of the startattach parameter, passed via link.
    can_send_after?: number; // Optional. Time in seconds, after which a message can be sent via the answerWebAppQuery method.
    auth_date: number; // Unix time when the form was opened.
    hash: string; // A hash of all passed parameters, which the bot server can use to check their validity.
  }

  interface WebAppInvoice {
    url: string;
    callback?: (status: string) => void;
  }

  interface BiometricRequestAccessParams {
    reason?: string; // Optional. The text to be displayed to a user in the popup describing why the bot needs access to biometrics, 0-128 characters.
  }

  interface BiometricAuthenticateParams {
    reason?: string; // Optional. The text to be displayed to a user in the popup describing why you are asking them to authenticate and what action you will be taking based on that authentication, 0-128 characters.
  }

  interface BiometricManager {
    isInited: boolean; // Bot API 7.2+ Shows whether biometrics object is initialized.
    isBiometricAvailable: boolean; // Bot API 7.2+ Shows whether biometrics is available on the current device.
    biometricType: 'finger' | 'face' | 'unknown'; // Bot API 7.2+ The type of biometrics currently available on the device.
    isAccessRequested: boolean; // Bot API 7.2+ Shows whether permission to use biometrics has been requested.
    isAccessGranted: boolean; // Bot API 7.2+ Shows whether permission to use biometrics has been granted.
    isBiometricTokenSaved: boolean; // Bot API 7.2+ Shows whether the token is saved in secure storage on the device.
    deviceId: string; // Bot API 7.2+ A unique device identifier that can be used to match the token to the device.
    init(callback?: () => void): BiometricManager; // Bot API 7.2+ A method that initializes the BiometricManager object.
    requestAccess(
      params: BiometricRequestAccessParams,
      callback?: (isAccessGranted: boolean) => void,
    ): BiometricManager; // Bot API 7.2+ A method that requests permission to use biometrics.
    authenticate(
      params: BiometricAuthenticateParams,
      callback?: (isAuthenticated: boolean, biometricToken?: string) => void,
    ): BiometricManager; // Bot API 7.2+ A method that authenticates the user using biometrics.
    updateBiometricToken(
      token: string,
      callback?: (isUpdated: boolean) => void,
    ): BiometricManager; // Bot API 7.2+ A method that updates the biometric token in secure storage on the device.
    openSettings(): BiometricManager; // Bot API 7.2+ A method that opens the biometric access settings for bots.
  }

  interface CloudStorage {
    setItem(
      key: string,
      value: string,
      callback?: (err: any, success: boolean) => void,
    ): CloudStorage; // Bot API 6.9+ A method that stores a value in the cloud storage using the specified key.
    getItem(
      key: string,
      callback: (err: any, value: string | null) => void,
    ): CloudStorage; // Bot API 6.9+ A method that receives a value from the cloud storage using the specified key.
    getItems(
      keys: string[],
      callback: (err: any, values: { [key: string]: string }) => void,
    ): CloudStorage; // Bot API 6.9+ A method that receives values from the cloud storage using the specified keys.
    removeItem(
      key: string,
      callback?: (err: any, success: boolean) => void,
    ): CloudStorage; // Bot API 6.9+ A method that removes a value from the cloud storage using the specified key.
    removeItems(
      keys: string[],
      callback?: (err: any, success: boolean) => void,
    ): CloudStorage; // Bot API 6.9+ A method that removes values from the cloud storage using the specified keys.
    getKeys(callback: (err: any, keys: string[]) => void): CloudStorage; // Bot API 6.9+ A method that receives the list of all keys stored in the cloud storage.
  }

  interface BackButton {
    isVisible: boolean; // Shows whether the button is visible. Set to false by default.
    onClick(callback: () => void): BackButton; // Bot API 6.1+ A method that sets the button press event handler.
    offClick(callback: () => void): BackButton; // Bot API 6.1+ A method that removes the button press event handler.
    show(): BackButton; // Bot API 6.1+ A method to make the button active and visible.
    hide(): BackButton; // Bot API 6.1+ A method to hide the button.
  }

  interface MainButton {
    text: string; // Current button text. Set to CONTINUE by default.
    color: string; // Current button color. Set to themeParams.button_color by default.
    textColor: string; // Current button text color. Set to themeParams.button_text_color by default.
    isVisible: boolean; // Shows whether the button is visible. Set to false by default.
    isActive: boolean; // Shows whether the button is active. Set to true by default.
    isProgressVisible: boolean; // Readonly. Shows whether the button is displaying a loading indicator.
    setText(text: string): MainButton; // A method to set the button text.
    onClick(callback: () => void): MainButton; // A method that sets the button press event handler.
    offClick(callback: () => void): MainButton; // A method that removes the button press event handler.
    show(): MainButton; // A method to make the button visible.
    hide(): MainButton; // A method to hide the button.
    enable(): MainButton; // A method to enable the button.
    disable(): MainButton; // A method to disable the button.
    showProgress(leaveActive?: boolean): MainButton; // A method to show a loading indicator on the button.
    hideProgress(): MainButton; // A method to hide the loading indicator.
    setParams(params: {
      text?: string;
      color?: string;
      text_color?: string;
      is_active?: boolean;
      is_visible?: boolean;
    }): MainButton; // A method to set the button parameters.
  }

  interface SettingsButton {
    isVisible: boolean; // Shows whether the context menu item is visible. Set to false by default.
    onClick(callback: () => void): SettingsButton; // Bot API 7.0+ A method that sets the press event handler for the Settings item in the context menu.
    offClick(callback: () => void): SettingsButton; // Bot API 7.0+ A method that removes the press event handler from the Settings item in the context menu.
    show(): SettingsButton; // Bot API 7.0+ A method to make the Settings item in the context menu visible.
    hide(): SettingsButton; // Bot API 7.0+ A method to hide the Settings item in the context menu.
  }

  interface HapticFeedback {
    impactOccurred(
      style: 'light' | 'medium' | 'heavy' | 'rigid' | 'soft',
    ): HapticFeedback; // Bot API 6.1+ A method that tells that an impact occurred.
    notificationOccurred(type: 'error' | 'success' | 'warning'): HapticFeedback; // Bot API 6.1+ A method that tells that a task or action has succeeded, failed, or produced a warning.
    selectionChanged(): HapticFeedback; // Bot API 6.1+ A method that tells that the user has changed a selection.
  }

  interface WebApp {
    initData: string;
    initDataUnsafe: WebAppInitDataUnsafe;
    version: string;
    platform: string;
    colorScheme: string;
    themeParams: ThemeParams;
    isExpanded: boolean;
    viewportHeight: number;
    viewportStableHeight: number;
    isClosingConfirmationEnabled: boolean;
    headerColor: string;
    backgroundColor: string;
    BackButton: BackButton;
    MainButton: MainButton;
    SettingsButton: SettingsButton;
    HapticFeedback: HapticFeedback;
    CloudStorage: CloudStorage;
    BiometricManager: BiometricManager;
    disableVerticalSwipes(): void;
    enableVerticalSwipes(): void;
    setHeaderColor(color_key: string): void;
    setBackgroundColor(color: string): void;
    enableClosingConfirmation(): void;
    disableClosingConfirmation(): void;
    isVersionAtLeast(ver: string): boolean;
    onEvent(eventType: string, callback: Function): void;
    offEvent(eventType: string, callback: Function): void;
    sendData(data: string): void;
    switchInlineQuery(query: string, choose_chat_types?: string[]): void;
    openLink(
      url: string,
      options?: { try_instant_view?: boolean; try_browser?: boolean },
    ): void;
    openTelegramLink(url: string): void;
    openInvoice(url: string, callback?: (status: string) => void): void;
    showPopup(
      params: PopupParams,
      callback?: (button_id: string | null) => void,
    ): void;
    showAlert(message: string, callback?: () => void): void;
    showConfirm(message: string, callback?: (result: boolean) => void): void;
    showScanQrPopup(
      params: { text?: string },
      callback?: (data: string | null) => boolean,
    ): void;
    closeScanQrPopup(): void;
    readTextFromClipboard(callback: (data: string | null) => void): void;
    requestWriteAccess(callback: (status: boolean) => void): void;
    requestContact(callback: (status: boolean, response?: any) => void): void;
    invokeCustomMethod(
      method: string,
      params: any,
      callback?: (err: any, res: any) => void,
    ): void;
    ready(): void;
    expand(): void;
    close(options?: { return_back?: boolean }): void;
  }

  interface Utils {
    urlSafeDecode(urlencoded: string): string;
    urlParseQueryString(queryString: string): { [key: string]: string | null };
    urlParseHashParams(locationHash: string): { [key: string]: any };
    urlAppendHashParams(url: string, addHash: string): string;
    sessionStorageSet(key: string, value: any): boolean;
    sessionStorageGet(key: string): any;
  }

  type WebAppEventHandler = () => void;
  type WebAppEventHandlerWithState = (params: {
    isStateStable: boolean;
  }) => void;
  type WebAppEventHandlerWithUrlStatus = (params: {
    url: string;
    status: 'paid' | 'cancelled' | 'failed' | 'pending';
  }) => void;
  type WebAppEventHandlerWithButtonId = (params: {
    button_id: string | null;
  }) => void;
  type WebAppEventHandlerWithData = (params: { data: string | null }) => void;
  type WebAppEventHandlerWithStatus = (params: {
    status: 'allowed' | 'cancelled' | 'sent';
  }) => void;
  type WebAppEventHandlerWithAuth = (params: {
    isAuthenticated: boolean;
    biometricToken?: string;
  }) => void;
  type WebAppEventHandlerWithUpdate = (params: { isUpdated: boolean }) => void;

  type ThemeParams = {
    accent_text_color: '#8774e1';
    bg_color: '#212121';
    button_color: '#8774e1';
    button_text_color: '#ffffff';
    destructive_text_color: '#ff595a';
    header_bg_color: '#212121';
    hint_color: '#aaaaaa';
    link_color: '#8774e1';
    secondary_bg_color: '#181818';
    section_bg_color: '#212121';
    section_header_text_color: '#8774e1';
    subtitle_text_color: '#aaaaaa';
    text_color: '#ffffff';
  };

  const WebView: {
    initParams: InitParams;
    isIframe: boolean;
    onEvent(eventType: 'themeChanged', eventHandler: WebAppEventHandler): void;
    onEvent(
      eventType: 'viewportChanged',
      eventHandler: WebAppEventHandlerWithState,
    ): void;
    onEvent(
      eventType: 'mainButtonClicked',
      eventHandler: WebAppEventHandler,
    ): void;
    onEvent(
      eventType: 'backButtonClicked',
      eventHandler: WebAppEventHandler,
    ): void;
    onEvent(
      eventType: 'settingsButtonClicked',
      eventHandler: WebAppEventHandler,
    ): void;
    onEvent(
      eventType: 'invoiceClosed',
      eventHandler: WebAppEventHandlerWithUrlStatus,
    ): void;
    onEvent(
      eventType: 'popupClosed',
      eventHandler: WebAppEventHandlerWithButtonId,
    ): void;
    onEvent(
      eventType: 'qrTextReceived',
      eventHandler: WebAppEventHandlerWithData,
    ): void;
    onEvent(
      eventType: 'clipboardTextReceived',
      eventHandler: WebAppEventHandlerWithData,
    ): void;
    onEvent(
      eventType: 'writeAccessRequested',
      eventHandler: WebAppEventHandlerWithStatus,
    ): void;
    onEvent(
      eventType: 'contactRequested',
      eventHandler: WebAppEventHandlerWithStatus,
    ): void;
    onEvent(
      eventType: 'biometricManagerUpdated',
      eventHandler: WebAppEventHandler,
    ): void;
    onEvent(
      eventType: 'biometricAuthRequested',
      eventHandler: WebAppEventHandlerWithAuth,
    ): void;
    onEvent(
      eventType: 'biometricTokenUpdated',
      eventHandler: WebAppEventHandlerWithUpdate,
    ): void;
    offEvent(eventType: string, callback: Function): void;
    postEvent(
      eventType: string,
      callback: Function | false,
      eventData?: any,
    ): void;
    receiveEvent(eventType: string, eventData: any): void;
    callEventCallbacks(
      eventType: string,
      func: (callback: Function) => void,
    ): void;
  };

  const Utils: Utils;

  const WebApp: WebApp;
}
