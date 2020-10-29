//
//  iCloudHelper.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 24.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import CryptoKit

class iCloudHelper: NSObject {
    
    var query: NSMetadataQuery!
    
    let documents = "Documents"
    var fileName = ""
    let fileExtension = "txt"
    var file: String {
        return "\(fileName).\(fileExtension)"
    }
    let fileManager = FileManager.default
    
    override init() {
        super.init()
        
        initialiseQuery()
        addNotificationObservers()
    }
    
    private func initialiseQuery() {
        
        query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, file)
    }
    
    func startBackup(fileName: String, password: String) throws {
        self.fileName = fileName
        guard let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString),
            let documentsURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(documents),
            let data = mnemonicString.data(using: .utf8) else { return }
        
        let encryptedData = try ChaChaPoly.seal(data, using: password.key())
        if !fileManager.fileExists(atPath: documentsURL.path, isDirectory: nil) {
            try fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let backupFileURL = documentsURL.appendingPathComponent(file)
        if FileManager.default.fileExists(atPath: backupFileURL.path) {
            try FileManager.default.removeItem(at: backupFileURL)
        }
        print("SAVE: ", encryptedData.combined.base64EncodedData())
        try encryptedData.combined.base64EncodedString().write(to: backupFileURL, atomically: true, encoding: .utf8)
        
        query.operationQueue?.addOperation({ [weak self] in
            _ = self?.query.start()
            self?.query.enableUpdates()
        })
    }
    
    private func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { (notification) in
            self.processCloudFiles()
        }
    }
    
    
    @objc private func processCloudFiles() {
        print("QUERY COUNT: ", query.resultCount, query.results.count)
        if query.results.count == 0 { return }
        var fileItem: NSMetadataItem?
        
        var fileURL: URL?
        
        for item in query.results {
            
            guard let item = item as? NSMetadataItem else { continue }
            guard let fileItemURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { continue }
            if fileItemURL.lastPathComponent.contains(file) {
                fileItem = item
                fileURL = fileItemURL
            }
        }
        
        let fileValues = try? fileURL?.resourceValues(forKeys: [URLResourceKey.ubiquitousItemIsUploadingKey])
        if let fileUploaded = fileItem?.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool, fileUploaded == true, fileValues?.ubiquitousItemIsUploading == false {
            print("backup upload complete")
            NotificationCenter.default.post(name: Notification.Name.iCloudBackupSuccess, object: nil)
            
        } else if let error = fileValues?.ubiquitousItemUploadingError {
            print("upload error---", error.localizedDescription)
            NotificationCenter.default.post(name: Notification.Name.iCloudBackupSuccess, object: nil, userInfo: ["error" : error as Any])
            
        } else {
            if let fileProgress = fileItem?.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double {
                print("uploaded percent ---", fileProgress)
            }
        }
    }
    
    func retrieveMnemonicFromiCloud(fileName: String, password: String) throws -> String? {
        guard let mnemonicURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(documents).appendingPathComponent(fileName),
            let data = FileManager.default.contents(atPath: mnemonicURL.path) else { return nil }
            let str = try String(contentsOf: mnemonicURL)
            print("RETRIEVE: ", str)
            if let newData = Data(base64Encoded: str) {
            
                let sealedBox = try ChaChaPoly.SealedBox(combined: newData)
                let decryptedData = try ChaChaPoly.open(sealedBox, using: password.key())
                let mnemonic = String(bytes: decryptedData, encoding: .utf8)
                return mnemonic
            } else {
                throw ACError(message: "ERROR_UNKNOWN".localized())
        }
    }
    
    func getMnemonicFiles() -> [String] {
        var names = [String]()
        if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"), let content = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            
            for file in content {
                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: file)
                } catch {
                    print(error)
                    print("")
                }
                if let fileName = file.pathComponents.last {
                    names.append(fileName)
                    
                }
            }
        }
        return names
    }
}

