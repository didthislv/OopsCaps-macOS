import Cocoa
import Carbon
import IOKit

// Valodu un tekstu menedžeris
struct Strings {
    static func TraySettings(_ l: String) -> String { return l == "lv" ? "Iestatījumi..." : (l == "ru" ? "Настройки..." : "Settings...") }
    static func TrayExit(_ l: String) -> String { return l == "lv" ? "Iziet (OopsCaps)" : (l == "ru" ? "Выход (OopsCaps)" : "Exit (OopsCaps)") }
    static func SettingsTitle(_ l: String) -> String { return l == "lv" ? "Iestatījumi" : (l == "ru" ? "Настройки" : "Settings") }
    static func GrpHotkeys(_ l: String) -> String { return l == "lv" ? "Karstie taustiņi (kopīgie modifikatori)" : (l == "ru" ? "Горячие клавиши (общие модификаторы)" : "Hotkeys (shared modifiers)") }
    static func GrpOptions(_ l: String) -> String { return l == "lv" ? "Iespējas" : (l == "ru" ? "Опции" : "Options") }
    static func LblInv(_ l: String) -> String { return l == "lv" ? "Invertēt:" : (l == "ru" ? "Инверт:" : "Invert:") }
    static func LblUpr(_ l: String) -> String { return l == "lv" ? "LIELIE:" : (l == "ru" ? "КРУПНЫЕ:" : "UPPER:") }
    static func LblLwr(_ l: String) -> String { return l == "lv" ? "mazie:" : (l == "ru" ? "мелкие:" : "lower:") }
    static func LblTtl(_ l: String) -> String { return l == "lv" ? "Titulburti:" : (l == "ru" ? "Заглавные:" : "Title Case:") }
    static func ChkAuto(_ l: String) -> String { return l == "lv" ? "Startēt ar Mac" : (l == "ru" ? "Запуск с Mac" : "Start with Mac") }
    static func ChkSnd(_ l: String) -> String { return l == "lv" ? "Skaņas signāls" : (l == "ru" ? "Звуковой сигнал" : "Sound effect") }
    
    // Sadalīts divās daļās
    static func ChkCaps(_ l: String) -> String { return l == "lv" ? "Pārslēgt Caps Lock" : (l == "ru" ? "Переключать Caps Lock" : "Toggle Caps Lock") }
    static func ChkCapsSub(_ l: String) -> String { return l == "lv" ? "(pēc invertēšanas)" : (l == "ru" ? "(после инверсии)" : "(after invert)") }
    
    static func LblLang(_ l: String) -> String { return l == "lv" ? "Izvēlies valodu:" : (l == "ru" ? "Выберите язык:" : "Language:") }
    static func LblSupport(_ l: String) -> String { return l == "lv" ? "Atbalsti projektu:" : (l == "ru" ? "Поддержать проект:" : "Support the project:") }
    static func BtnSave(_ l: String) -> String { return l == "lv" ? "Saglabāt" : (l == "ru" ? "Сохранить" : "Save") }
    static func VerAuth(_ l: String) -> String { return l == "lv" ? "Versija 1.0\n© 2026 didthis.lv" : (l == "ru" ? "Версия 1.0\n© 2026 didthis.lv" : "Version 1.0\n© 2026 didthis.lv") }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow!
    
    // UI Elementi
    var chkCmd: NSButton!, chkShift: NSButton!, chkOpt: NSButton!, chkCaps: NSButton!
    var cmbInv: NSPopUpButton!, cmbUpr: NSPopUpButton!, cmbLwr: NSPopUpButton!, cmbTtl: NSPopUpButton!
    var cmbLang: NSPopUpButton!, chkAuto: NSButton!, chkSound: NSButton!
    var lblInv: NSTextField!, lblUpr: NSTextField!, lblLwr: NSTextField!, lblTtl: NSTextField!
    var lblLang: NSTextField!, lblSupport: NSTextField!, lblVerAuth: NSTextField!, btnSave: NSButton!
    var lblCapsSub: NSTextField! // Jaunais teksta lauks paskaidrojumam
    var grpHotkeys: NSBox!, grpOptions: NSBox!
    var trayMenu: NSMenu!

    // Mainīgie
    var lang = "en"
    var playSound = true
    var syncCapsLock = true
    var useCmd = true, useShift = true, useOpt = false
    var charInv = "I", charUpr = "U", charLwr = "L", charTtl = "T"
    
    var registeredHotkeys: [EventHotKeyRef?] = [nil, nil, nil, nil]

    let macKeyMap: [String: UInt16] = ["A":0,"B":11,"C":8,"D":2,"E":14,"F":3,"G":5,"H":4,"I":34,"J":38,"K":40,"L":37,"M":46,"N":45,"O":31,"P":35,"Q":12,"R":15,"S":1,"T":17,"U":32,"V":9,"W":13,"X":7,"Y":16,"Z":6]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadSettings()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = generateOoImage(size: 18)
        }
        buildMenu()
        
        let windowRect = NSRect(x: 0, y: 0, width: 420, height: 480)
        settingsWindow = NSWindow(contentRect: windowRect, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        settingsWindow.center()
        settingsWindow.isReleasedWhenClosed = false
        
        setupSettingsUI()
        updateTexts()
        applyHotkeys()
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let ptr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            
            let mySelf = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
            mySelf.transformText(mode: Int(hotKeyID.id))
            return noErr
        }, 1, &eventType, ptr, nil)
    }

    func buildMenu() {
        trayMenu = NSMenu()
        trayMenu.addItem(NSMenuItem(title: Strings.TraySettings(lang), action: #selector(showSettings), keyEquivalent: ""))
        trayMenu.addItem(NSMenuItem.separator())
        trayMenu.addItem(NSMenuItem(title: Strings.TrayExit(lang), action: #selector(quitApp), keyEquivalent: ""))
        statusItem.menu = trayMenu
    }

    @objc func showSettings() {
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() { NSApp.terminate(nil) }

    func setupSettingsUI() {
        guard let view = settingsWindow.contentView else { return }
        
        grpHotkeys = NSBox(frame: NSRect(x: 15, y: 295, width: 390, height: 165))
        
        chkCmd = createCheck(title: "Cmd", x: 20, y: 114, checked: useCmd, parent: grpHotkeys)
        chkShift = createCheck(title: "Shift", x: 20, y: 84, checked: useShift, parent: grpHotkeys)
        chkOpt = createCheck(title: "Option (Alt)", x: 20, y: 54, checked: useOpt, parent: grpHotkeys)
        chkCaps = createCheck(title: "Toggle Caps Lock", x: 20, y: 24, checked: syncCapsLock, parent: grpHotkeys)
        
        // Jaunais paskaidrojošais teksts tieši zem ķekša
        lblCapsSub = createLabel(x: 38, y: 8, parent: grpHotkeys)
        lblCapsSub.frame = NSRect(x: 38, y: 8, width: 150, height: 16)
        lblCapsSub.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        lblCapsSub.textColor = .secondaryLabelColor
        
        lblTtl = createLabel(x: 200, y: 22, parent: grpHotkeys); cmbTtl = createCombo(val: charTtl, x: 280, y: 20, parent: grpHotkeys)
        lblLwr = createLabel(x: 200, y: 52, parent: grpHotkeys); cmbLwr = createCombo(val: charLwr, x: 280, y: 50, parent: grpHotkeys)
        lblUpr = createLabel(x: 200, y: 82, parent: grpHotkeys); cmbUpr = createCombo(val: charUpr, x: 280, y: 80, parent: grpHotkeys)
        lblInv = createLabel(x: 200, y: 112, parent: grpHotkeys); cmbInv = createCombo(val: charInv, x: 280, y: 110, parent: grpHotkeys)
        view.addSubview(grpHotkeys)
        
        grpOptions = NSBox(frame: NSRect(x: 15, y: 175, width: 390, height: 105))
        lblLang = createLabel(x: 20, y: 45, parent: grpOptions)
        cmbLang = NSPopUpButton(frame: NSRect(x: 18, y: 15, width: 150, height: 25), pullsDown: false)
        cmbLang.addItems(withTitles: ["English", "Latviešu", "Русский"])
        cmbLang.selectItem(at: lang == "ru" ? 2 : (lang == "lv" ? 1 : 0))
        cmbLang.action = #selector(langChanged)
        cmbLang.target = self
        grpOptions.addSubview(cmbLang)

        chkAuto = createCheck(title: "Auto", x: 210, y: 45, checked: isAutoStartEnabled(), parent: grpOptions)        
        chkSound = createCheck(title: "Sound", x: 210, y: 15, checked: playSound, parent: grpOptions)
        view.addSubview(grpOptions)
        
        let picLogo = NSImageView(frame: NSRect(x: 20, y: 65, width: 80, height: 80))
        picLogo.image = generateOoImage(size: 80)
        view.addSubview(picLogo)
        
        lblVerAuth = createLabel(x: 120, y: 105, parent: view)
        lblVerAuth.frame = NSRect(x: 120, y: 105, width: 150, height: 35)
        lblVerAuth.font = NSFont.systemFont(ofSize: 12, weight: .light)
        
        let lnkGit = NSButton(frame: NSRect(x: 110, y: 80, width: 140, height: 20))
        lnkGit.title = "github.com/didthislv"; lnkGit.isBordered = false; lnkGit.contentTintColor = .linkColor
        lnkGit.action = #selector(openGit); lnkGit.target = self
        view.addSubview(lnkGit)
        
        lblSupport = createLabel(x: 270, y: 115, parent: view); lblSupport.font = NSFont.boldSystemFont(ofSize: 12)
        
        let btnCoffee = NSButton(frame: NSRect(x: 260, y: 80, width: 140, height: 27))
        btnCoffee.isBordered = false
        btnCoffee.wantsLayer = true
        btnCoffee.layer?.backgroundColor = NSColor(red: 1.0, green: 0.81, blue: 0.0, alpha: 1.0).cgColor
        btnCoffee.layer?.cornerRadius = 4.0
        btnCoffee.layer?.borderWidth = 1.0
        btnCoffee.layer?.borderColor = NSColor.gray.cgColor
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        let btnAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.black,
            .paragraphStyle: pStyle
        ]
        btnCoffee.attributedTitle = NSAttributedString(string: "☕ Buy me a coffee", attributes: btnAttr)
        btnCoffee.action = #selector(openCoffee); btnCoffee.target = self
        view.addSubview(btnCoffee)
        
        btnSave = NSButton(frame: NSRect(x: 160, y: 15, width: 100, height: 35))
        btnSave.bezelStyle = .rounded; btnSave.action = #selector(saveClicked); btnSave.target = self
        view.addSubview(btnSave)
    }

    func createCheck(title: String, x: CGFloat, y: CGFloat, checked: Bool, parent: NSView) -> NSButton {
        let btn = NSButton(checkboxWithTitle: title, target: nil, action: nil)
        btn.frame = NSRect(x: x, y: y, width: 150, height: 20); btn.state = checked ? .on : .off
        parent.addSubview(btn); return btn
    }
    
    func createLabel(x: CGFloat, y: CGFloat, parent: NSView) -> NSTextField {
        let lbl = NSTextField(labelWithString: ""); lbl.frame = NSRect(x: x, y: y, width: 150, height: 20)
        lbl.isEditable = false; lbl.isBordered = false; lbl.drawsBackground = false
        parent.addSubview(lbl); return lbl
    }
    
    func createCombo(val: String, x: CGFloat, y: CGFloat, parent: NSView) -> NSPopUpButton {
        let cmb = NSPopUpButton(frame: NSRect(x: x, y: y, width: 60, height: 25), pullsDown: false)
        for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" { cmb.addItem(withTitle: String(c)) }
        cmb.selectItem(withTitle: val)
        parent.addSubview(cmb); return cmb
    }

    @objc func langChanged() {
        let idx = cmbLang.indexOfSelectedItem
        lang = idx == 2 ? "ru" : (idx == 1 ? "lv" : "en")
        updateTexts()
    }
    
    func updateTexts() {
        settingsWindow.title = Strings.SettingsTitle(lang)
        grpHotkeys.title = Strings.GrpHotkeys(lang)
        grpOptions.title = Strings.GrpOptions(lang)
        lblInv.stringValue = Strings.LblInv(lang)
        lblUpr.stringValue = Strings.LblUpr(lang)
        lblLwr.stringValue = Strings.LblLwr(lang)
        lblTtl.stringValue = Strings.LblTtl(lang)
        chkAuto.title = Strings.ChkAuto(lang)
        chkSound.title = Strings.ChkSnd(lang)
        chkCaps.title = Strings.ChkCaps(lang)
        lblCapsSub.stringValue = Strings.ChkCapsSub(lang) // Atjaunina mazo tekstu apakšā
        lblLang.stringValue = Strings.LblLang(lang)
        lblSupport.stringValue = Strings.LblSupport(lang)
        lblVerAuth.stringValue = Strings.VerAuth(lang)
        btnSave.title = Strings.BtnSave(lang)
        trayMenu.item(at: 0)?.title = Strings.TraySettings(lang)
        trayMenu.item(at: 2)?.title = Strings.TrayExit(lang)
    }

    @objc func openGit() { NSWorkspace.shared.open(URL(string: "https://github.com/didthislv")!) }
    @objc func openCoffee() { NSWorkspace.shared.open(URL(string: "https://www.buymeacoffee.com/didthislv")!) }

    @objc func saveClicked() {
        useCmd = chkCmd.state == .on; useShift = chkShift.state == .on; useOpt = chkOpt.state == .on
        syncCapsLock = chkCaps.state == .on
        charInv = cmbInv.titleOfSelectedItem ?? "I"; charUpr = cmbUpr.titleOfSelectedItem ?? "U"
        charLwr = cmbLwr.titleOfSelectedItem ?? "L"; charTtl = cmbTtl.titleOfSelectedItem ?? "T"
        playSound = chkSound.state == .on
        
        saveSettings()
        applyHotkeys()
        setAutoStart(enabled: chkAuto.state == .on)
        settingsWindow.close()
    }

    func loadSettings() {
        let defs = UserDefaults.standard
        if defs.object(forKey: "lang") != nil {
            lang = defs.string(forKey: "lang") ?? "en"
            useCmd = defs.bool(forKey: "useCmd"); useShift = defs.bool(forKey: "useShift"); useOpt = defs.bool(forKey: "useOpt")
            if defs.object(forKey: "syncCapsLock") != nil { syncCapsLock = defs.bool(forKey: "syncCapsLock") }
            playSound = defs.bool(forKey: "playSound")
            charInv = defs.string(forKey: "charInv") ?? "I"; charUpr = defs.string(forKey: "charUpr") ?? "U"
            charLwr = defs.string(forKey: "charLwr") ?? "L"; charTtl = defs.string(forKey: "charTtl") ?? "T"
        }
    }
    
    func saveSettings() {
        let defs = UserDefaults.standard
        defs.set(lang, forKey: "lang"); defs.set(useCmd, forKey: "useCmd"); defs.set(useShift, forKey: "useShift"); defs.set(useOpt, forKey: "useOpt")
        defs.set(syncCapsLock, forKey: "syncCapsLock")
        defs.set(playSound, forKey: "playSound"); defs.set(charInv, forKey: "charInv"); defs.set(charUpr, forKey: "charUpr")
        defs.set(charLwr, forKey: "charLwr"); defs.set(charTtl, forKey: "charTtl")
    }

    func applyHotkeys() {
        var mods: UInt32 = 0
        if useCmd { mods |= UInt32(cmdKey) }
        if useShift { mods |= UInt32(shiftKey) }
        if useOpt { mods |= UInt32(optionKey) }
        for i in 0..<4 { if let ref = registeredHotkeys[i] { UnregisterEventHotKey(ref) } }
        registerKey(id: 1, letter: charInv, mods: mods); registerKey(id: 2, letter: charUpr, mods: mods)
        registerKey(id: 3, letter: charLwr, mods: mods); registerKey(id: 4, letter: charTtl, mods: mods)
    }
    
    func registerKey(id: UInt32, letter: String, mods: UInt32) {
        guard let code = macKeyMap[letter] else { return }
        var hotKeyID = EventHotKeyID(); hotKeyID.id = id; hotKeyID.signature = 0x4F6F7073
        var ref: EventHotKeyRef?
        RegisterEventHotKey(UInt32(code), mods, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        registeredHotkeys[Int(id)-1] = ref
    }

    func toggleHardwareCapsLock() {
        let ioService = IOServiceGetMatchingService(mach_port_t(0), IOServiceMatching("IOHIDSystem"))
        if ioService != 0 {
            var ioConnect: io_connect_t = 0
            if IOServiceOpen(ioService, mach_task_self_, 1, &ioConnect) == KERN_SUCCESS {
                var state: Bool = false
                IOHIDGetModifierLockState(ioConnect, Int32(1), &state)
                IOHIDSetModifierLockState(ioConnect, Int32(1), !state)
                IOServiceClose(ioConnect)
            }
            IOObjectRelease(ioService)
        }
    }

    func transformText(mode: Int) {
        let pb = NSPasteboard.general
        let old = pb.string(forType: .string)
        pb.clearContents()
        simulateKey(keyCode: 8, flags: .maskCommand) // Cmd+C
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if let text = pb.string(forType: .string) {
                var fixedText = text
                
                if mode == 1 { 
                    fixedText = text.map { String($0) == String($0).uppercased() ? String($0).lowercased() : String($0).uppercased() }.joined() 
                    
                    if self.syncCapsLock {
                        self.toggleHardwareCapsLock()
                    }
                }
                else if mode == 2 { fixedText = text.uppercased() }
                else if mode == 3 { fixedText = text.lowercased() }
                else if mode == 4 { fixedText = text.capitalized }
                
                pb.clearContents(); pb.setString(fixedText, forType: .string)
                self.simulateKey(keyCode: 9, flags: .maskCommand) // Cmd+V
                
                if self.playSound { NSSound(named: NSSound.Name("Tink"))?.play() }
            }
            if let old = old { DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { pb.clearContents(); pb.setString(old, forType: .string) } }
        }
    }

    func simulateKey(keyCode: CGKeyCode, flags: CGEventFlags) {
        let src = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        down?.flags = flags; down?.post(tap: .cghidEventTap)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        up?.post(tap: .cghidEventTap)
    }

    func getPlistPath() -> URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents/lv.didthis.OopsCaps.plist")
    }
    
    func isAutoStartEnabled() -> Bool { return FileManager.default.fileExists(atPath: getPlistPath().path) }
    
    func setAutoStart(enabled: Bool) {
        let path = getPlistPath()
        if enabled {
            let exePath = Bundle.main.executablePath ?? ""
            let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key><string>lv.didthis.OopsCaps</string>
                <key>ProgramArguments</key><array><string>\(exePath)</string></array>
                <key>RunAtLoad</key><true/>
            </dict>
            </plist>
            """
            try? FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try? plist.write(to: path, atomically: true, encoding: .utf8)
        } else { try? FileManager.default.removeItem(at: path) }
    }

    func generateOoImage(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        let bounds = NSRect(x: 0, y: 0, width: size, height: size)
        let lineWidth = max(1.5, size * 0.06)
        let circleBounds = bounds.insetBy(dx: lineWidth / 2 + 1, dy: lineWidth / 2 + 1)
        NSColor.black.setFill(); NSBezierPath(ovalIn: circleBounds).fill()
        let purpleColor = NSColor(red: 180/255, green: 50/255, blue: 1.0, alpha: 1.0)
        purpleColor.setStroke()
        let circlePath = NSBezierPath(ovalIn: circleBounds); circlePath.lineWidth = lineWidth; circlePath.stroke()
        let paragraphStyle = NSMutableParagraphStyle(); paragraphStyle.alignment = .center
        let attr: [NSAttributedString.Key: Any] = [.font: NSFont(name: "ArialMT", size: size * 0.53) ?? NSFont.systemFont(ofSize: size * 0.45, weight: .bold), .foregroundColor: purpleColor, .paragraphStyle: paragraphStyle]
        let str = "Oo" as NSString
        str.draw(in: NSRect(x: 0, y: (size - str.size(withAttributes: attr).height) / 1.5 - (size * 0.05), width: size, height: str.size(withAttributes: attr).height), withAttributes: attr)
        image.unlockFocus()
        return image
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()