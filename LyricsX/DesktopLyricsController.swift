//
//  DesktopLyricsController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SnapKit

class DesktopLyricsController: NSWindowController, NSWindowDelegate {
    
    var backgroundView: NSView!
    var textView: NSTextField!
    
    var enabled = UserDefaults.standard.bool(forKey: DesktopLyricsEnabled)
    
    convenience init() {
        let lyricsWindow = NSWindow(contentRect: NSZeroRect, styleMask: [.borderless, .fullSizeContentView, .texturedBackground], backing: .buffered, defer: false)
        lyricsWindow.backgroundColor = .clear
        lyricsWindow.isOpaque = false
        lyricsWindow.hasShadow = false
        lyricsWindow.ignoresMouseEvents = true
        lyricsWindow.level = Int(CGWindowLevelForKey(.floatingWindow))
        lyricsWindow.collectionBehavior = .canJoinAllSpaces
        lyricsWindow.contentView?.wantsLayer=true
        self.init(window: lyricsWindow)
        guard let window = self.window else {
            return
        }
        let visibleFrame = NSScreen.main()!.visibleFrame
        window.setFrame(visibleFrame, display: true)
        window.delegate = self
        
        let superView = window.contentView!
        
        backgroundView = NSView()
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = CGColor(gray: 0, alpha: 0.5)
        backgroundView.layer?.cornerRadius = 10
        
        textView = NSTextField(wrappingLabelWithString: "LyricsX")
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 28)
        textView.alignment = .center
        
        backgroundView.addSubview(textView)
        superView.addSubview(backgroundView)
        
        textView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(EdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
        
        backgroundView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            guard self.enabled else {
                return
            }
            
            let lrc = n.userInfo?["lrc"] as? String ?? ""
            self.backgroundView.isHidden = lrc == ""
            if let next = n.userInfo?["next"] as? String, next != "" {
                self.textView.stringValue = lrc + "\n" + next
            } else {
                self.textView.stringValue = lrc
            }
        }
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { n in
            self.enabled = UserDefaults.standard.bool(forKey: DesktopLyricsEnabled)
            self.backgroundView.isHidden = !self.enabled
        }
    }
    
}
