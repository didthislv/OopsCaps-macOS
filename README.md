# OopsCaps

**OopsCaps** is a fast, lightweight, and efficient text transformation utility for macOS. Accidentally typed with Caps Lock on? No need to rewrite – instantly transform your text to the desired format with a single hotkey combination.

## Features

* **Instant Text Transformations:**
    * **Invert Case** (iNVERT cASE)
    * **UPPERCASE**
    * **lowercase**
    * **Title Case**
* **Smart Caps Lock Toggle:** Automatically disable your physical Caps Lock when performing an "Invert" transformation.
* **Customizable Hotkeys:** Set your own global modifier combinations (Cmd, Shift, Option).
* **Menu Bar Integration:** Discrete, efficient, and always available from your menu bar.
* **Lightweight:** Built with native Swift, consuming minimal system resources.
* **Auto-start:** Option to launch automatically on login.

## Installation

1. Download the latest version from the [GitHub Releases](https://github.com/didthislv/OopsCaps-macOS/) page.
2. Move `OopsCaps.app` to your **Applications** folder.
3. Launch the application.

## 🛡️ First Launch: macOS Gatekeeper Warning

Because OopsCaps is currently distributed outside the Mac App Store, macOS Gatekeeper might block it on your first launch. 

* **Scenario A:** A pop-up appears saying *"Apple could not verify OopsCaps..."*
* **Scenario B:** **Nothing happens at all**, and the app silently fails to open.

If the app doesn't launch or is blocked, don't worry! You just need to manually allow it to run:

1. Open **System Settings** on your Mac.
2. Navigate to **Privacy & Security** on the left sidebar.
3. Scroll down to the **Security** section.
4. You will see a message stating: *"OopsCaps" was blocked to protect your Mac.* Click **"Open Anyway"**.
5. Confirm with your Mac password or Touch ID, then click **Open**.

## ⚠️ Important: Accessibility Permissions

Because OopsCaps needs to monitor your keyboard and interact with the clipboard globally, **you must grant Accessibility permissions** to the app:

1. When you first launch the app, a system prompt will appear. Click **"Open System Preferences"** (or *Open System Settings* on newer macOS versions).
2. Go to **Privacy & Security > Privacy > Accessibility**.
3. Toggle the switch next to **OopsCaps** to enable it (you might need to enter your Mac password).
4. Restart the application.

## How to use

1. Click the **Oo** icon in your macOS Menu Bar to open the settings.
2. Configure your preferred hotkeys.
3. **Toggle Caps Lock (after invert):** Enable this option if you want the app to automatically turn off your physical Caps Lock key whenever you trigger an "Invert" transformation. This is perfect for when you realize you've been typing in all-caps by mistake!
4. Select text in any application, press your hotkey, and watch the magic happen!

## Support the project

If you find OopsCaps useful, consider buying me a coffee to support future development:

[☕ Buy me a coffee](https://www.buymeacoffee.com/didthislv)

## Credits

Developed by [didthis.lv] | [GitHub](https://github.com/didthislv)

## License

This project is open-source.