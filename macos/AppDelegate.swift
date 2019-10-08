// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import ZIPFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var applicationMenu: NSMenu!
    
    final var workFolder = ".bchain"
    var bchaindProcess: Process?
    
  func applicationWillFinishLaunching(_ notification: Notification) {
    // Update UI elements to match the application name.
    // TODO: Move this logic to a Flutter framework application delegate.
    // See https://github.com/flutter/flutter/issues/32419.
    let appName = applicationName()
    window.title = appName
    for menuItem in applicationMenu.items {
      menuItem.title = menuItem.title.replacingOccurrences(of: "APP_NAME", with: appName)
    }
    startBChaind()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
    
    func applicationWillTerminate(_ notification: Notification) {
        bchaindProcess?.terminate()
        bchaindProcess?.waitUntilExit()
        bchaindProcess = nil
    }
    
    private func startBChaind() {
        let homePath = NSHomeDirectory()
        let manager = FileManager()
        let workPath = "\(homePath)/\(workFolder)"
        let binPath = "\(workPath)/bchaind"
        guard let bundleZipUrl = Bundle.main.url(forResource: "bchain", withExtension: "zip") else {
            return
        }
        if !manager.fileExists(atPath: binPath) {
            try! manager.createDirectory(atPath: workPath, withIntermediateDirectories: true, attributes: nil)
            unzipBChainZip(manager: manager, url: bundleZipUrl, outputPath: workPath)
        } else {
            let currentVersion = try? String(contentsOfFile: "\(workPath)/version", encoding: String.Encoding.utf8)
            if (currentVersion != nil) {
                unzipBChainZip(manager: manager, url: bundleZipUrl, outputPath: workPath, oldVersion: currentVersion)
            }
        }
        bchaindProcess?.terminate()
        bchaindProcess?.waitUntilExit()
        let process = Process()
        process.currentDirectoryPath = workPath
        process.launchPath = binPath
        process.launch()
        bchaindProcess = process
    }
    
    private func unzipBChainZip(manager: FileManager, url: URL, outputPath: String, oldVersion: String? = nil) {
        let outputUrl = URL(fileURLWithPath: outputPath)
        guard let archive = Archive(url: url, accessMode: .read) else {
            return
        }
        
        if (oldVersion != nil) {
            guard let versionEntry = archive["version"] else {
                return
            }
            var notChange = false
            _ = try! archive.extract(versionEntry) { (data) in
                let bundleVersion = String(decoding: data, as: UTF8.self)
                if bundleVersion == oldVersion {
                    notChange = true
                }
            }
            if notChange {
                return
            }
        }
        
        let sortedEntries = archive.sorted { (left, right) -> Bool in
            switch (left.type, right.type) {
            case (.directory, .file): return true
            case (.directory, .symlink): return true
            case (.file, .symlink): return true
            default: return false
            }
        }
        
        for entry in sortedEntries {
            let destinationEntryURL = outputUrl.appendingPathComponent(entry.path)
            do {
                _ = try archive.extract(entry, to: destinationEntryURL)
            } catch {
                _ = try! manager.removeItem(at: destinationEntryURL)
                _ = try! archive.extract(entry, to: destinationEntryURL)
            }
        }
    }

  /**
   * Returns the name of the application as set in the Info.plist
   */
  private func applicationName() -> String {
    var applicationName : String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    if applicationName == nil {
      applicationName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    return applicationName!
  }
}

