//
//  FileManager.swift
//  ProtocolFileHandling
//
//  Created by Steven Curtis on 09/10/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import Foundation

let fileManager = FileManager.default

protocol AppDirectory
{
    func getURL(for searchPathDirectory: FileManager.SearchPathDirectory) -> URL?

    func buildFullURL(forFileName name: String, withSubDirectoryPath subDirectories: String, inDirectory directory: FileManager.SearchPathDirectory) -> URL?
}

extension AppDirectory
{
    
    func buildFullURL(forFileName name: String, withSubDirectoryPath subDirectories: String = "", inDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) -> URL? {
        
        if var newURL = getURL(for: directory) {
            for subDir in subDirectories.components(separatedBy: "/") {
                newURL = newURL.appendingPathComponent(subDir, isDirectory: true)
            }
            newURL = newURL.appendingPathComponent(name)
            return newURL
        }
        return nil
    }
    
    func getURL(for searchPathDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory) -> URL? {
        let urls = fileManager.urls(for: searchPathDirectory, in: .userDomainMask)
        if let applicationSupportURL = urls.last {
            return applicationSupportURL
        }
        return nil
    }
}



protocol AppFileStatus
{
    func exists(file atURL: URL) -> Bool
}

extension AppFileStatus
{
    func exists(file atURL: URL) -> Bool
    {
        return fileManager.fileExists(atPath: atURL.path)
    }
}

protocol AppFolderManipulation {
    func prepareSearchPathDirectories(withDirectories directories: [FileManager.SearchPathDirectory]?)
    func createDirectory(toDirectory directory: FileManager.SearchPathDirectory, withSubDirectoryPath subDirectories: String) -> Bool
    func removeDirectory(toDirectory directory: FileManager.SearchPathDirectory, withSubDirectoryPath subDirectories: String)
    func directoryExistsAtPath(_ path: String) -> Bool
    func directoryExistsAtURL(_ url: URL) -> Bool
}

extension AppFolderManipulation {
    func prepareSearchPathDirectories(withDirectories directories: [FileManager.SearchPathDirectory]? = [.applicationSupportDirectory]) {
        guard let directories = directories else {return}
        for dir in directories {
            _ = createDirectory(toDirectory: dir)
        }
    }
    
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false)
        return fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    }
    
    func directoryExistsAtURL(_ url: URL) -> Bool {
        let filePath = url.path
        return directoryExistsAtPath(filePath)
    }
    
    /// create a directory, if subDirectories are not given create the directory in the root of FileManager.SearchPathDirectory
    func createDirectory(toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory, withSubDirectoryPath subDirectories: String = "") -> Bool {
        let urls = fileManager.urls(for: directory, in: .userDomainMask)
        if let applicationSupportURL = urls.last {
            do{
                var newURL = applicationSupportURL
                for subDir in subDirectories.components(separatedBy: "/") {
                    newURL = newURL.appendingPathComponent(subDir, isDirectory: true)
                }
                try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
                return true
            }
            catch{
                print("error \(error)")
                return false
            }
        }
        return false
    }
    
    // does not stop a "required" FileManager.SearchPathDirectory from being removed
    func removeDirectory(toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory, withSubDirectoryPath subDirectories: String = "") {
        let fileManager = FileManager.default
        let path = FileManager.default.urls(for: directory, in: .userDomainMask)
        if var originURL = path.first {
            if let topDir = subDirectories.components(separatedBy: "/").first {
                originURL = originURL.appendingPathComponent(topDir)
            }
            
            do {
                try fileManager.removeItem(at: originURL)
                return
            }
            catch let error {
                print ("\(error) error")
            }
            

        }
    }
    
}

protocol AppFileManipulation : AppDirectory, AppFileStatus, AppFolderManipulation
{
    func createFileFromDataAtomically(withData data: Data?, withName name: String, toDirectory directory: FileManager.SearchPathDirectory)
    func writeStringsToFile(containing: String, to path: FileManager.SearchPathDirectory, withName name: String, withSubDirectoryPath subDirectories: String) -> Bool
    func writeDataToFile(containing: Data?, to directory: FileManager.SearchPathDirectory, withName name: String, withSubDirectoryPath subDirectories: String) -> Bool
    func createDataTempFile(withData data: Data?, withFileName name: String) -> URL?
    func copyFileAtomically(withOriginFileName name: String, withOriginSubDirectoryPath: String, withDestinationSubDirectoryPath destinationSubDirectories: String, originDirectory: FileManager.SearchPathDirectory, destinationDirectory: FileManager.SearchPathDirectory)
    func moveFileAtomically(withOriginFileName name: String, withOriginSubDirectoryPath: String, withDestinationSubDirectoryPath destinationSubDirectories: String, originDirectory: FileManager.SearchPathDirectory, destinationDirectory: FileManager.SearchPathDirectory)
    func removeItem(withItemName originName:String, withSubDirectory dir: String, toDirectory directory: FileManager.SearchPathDirectory)
}

extension AppFileManipulation {
    
    func removeItem(withItemName originName:String, withSubDirectory dir: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        let fileManger = FileManager.default
        let urls = FileManager.default.urls(for: directory, in: .userDomainMask)
        if let originURL = urls.first?.appendingPathComponent(dir + "/" + originName) {
            do {
                try fileManger.removeItem(at: originURL)
            }
            catch let error {
                print ("\(error) error")
            }
        }
    }
    
    func copyFile(withOriginName originName: String, withOriginSubDirectoryPath originSubDirectories: String, withDestinationName destinationName: String, withDestinationSubDirectoryPath destinationSubDirectories: String) {
        let fileManager = FileManager.default
        let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if var originURL = path.first {
            for subDirectory in originSubDirectories.components(separatedBy: "/") {
                originURL = originURL.appendingPathComponent(subDirectory)
            }
            originURL = originURL.appendingPathComponent(originName)
            if var destinationURL = path.first {
                for subDirectory in destinationSubDirectories.components(separatedBy: "/") {
                    destinationURL = destinationURL.appendingPathComponent(subDirectory)
                }
                destinationURL = destinationURL.appendingPathComponent(destinationName)
                do {
                    try fileManager.copyItem(at: originURL, to: destinationURL)
                }
                catch let error {
                    print ("\(error) error")
                }
            }
        }
    }
    
    func moveFileAtomically(withOriginFileName name: String, withOriginSubDirectoryPath: String, withDestinationSubDirectoryPath destinationSubDirectories: String, originDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory, destinationDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        
        
        copyFileAtomically(withOriginFileName: name, withOriginSubDirectoryPath: withOriginSubDirectoryPath, withDestinationSubDirectoryPath: destinationSubDirectories, originDirectory: originDirectory, destinationDirectory: destinationDirectory)
        
        removeItem(withItemName: name, withSubDirectory: withOriginSubDirectoryPath, toDirectory: originDirectory)
        
    }
    
    func copyFileAtomically(withOriginFileName name: String, withOriginSubDirectoryPath: String, withDestinationSubDirectoryPath destinationSubDirectories: String, originDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory, destinationDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        
        if let originalFileURL = buildFullURL(forFileName: name, withSubDirectoryPath: withOriginSubDirectoryPath, inDirectory: originDirectory) {
            guard exists(file: originalFileURL) else {return}
            do {
                let data = try Data(contentsOf: originalFileURL)
                if let fileURL = createDataTempFile(withData: data, withFileName: name) {
                    writeTempFile(withTempFile: fileURL, existingFileName: name, withDestinationSubDirectoryPath: destinationSubDirectories)
                }
            }
            catch let error {
                print ("error \(error)")
            }
        }
        
    }

    // write a temporary file into an existing file / create the existing file
    func writeTempFile(withTempFile fileURL: URL?, existingFileName: String, withDestinationSubDirectoryPath destinationSubDirectories: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        guard let fileURL = fileURL else {return}
        let fileManager = FileManager.default
        if var destURL = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            
            if !directoryExistsAtURL(destURL) {
                _ = createDirectory(toDirectory: directory, withSubDirectoryPath: destinationSubDirectories)
            }
            
            for subDirectory in destinationSubDirectories.components(separatedBy: "/") {
                destURL = destURL.appendingPathComponent(subDirectory)
            }
            
            destURL = destURL.appendingPathComponent(existingFileName)
            
            do {
                let dta = try Data(contentsOf: fileURL)
                try dta.write(to: destURL, options: [.atomic, .completeFileProtection])
            }
            catch let error {
                print ("\(error)")
            }
            
        }
    }

    
    // creates a temporary file in the root of .itemReplacementDirectory
    func createDataTempFile(withData data: Data?, withFileName name: String) -> URL? {
        if let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileManager = FileManager.default
            var itemReplacementDirectoryURL: URL?
            do {
                try itemReplacementDirectoryURL = fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: destinationURL, create: true)
            } catch let error {
                print ("error \(error)")
            }
            guard let destURL = itemReplacementDirectoryURL else {return nil}
            guard let data = data else {return nil}
            let tempFileURL = destURL.appendingPathComponent(name)
            do {
                try data.write(to: tempFileURL, options: [.atomic, .completeFileProtection])
                return tempFileURL
            } catch let error {
                print ("error \(error)")
                return nil
            }
        }
        return nil
    }
    
    
    
    func createFileFromStringAtomically(withString string: String, withName name: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory)  {
        let data = string.data(using: .utf8)
        createFileFromDataAtomically(withData: data, withName: name, toDirectory: directory)
    }
    
    func createFileFromDataAtomically(withData data: Data?, withName name: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory)  {
        let destPath = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fullDestPath = destPath?.appendingPathComponent(name), let data = data {
            do{
                try data.write(to: fullDestPath, options: [.atomic, .completeFileProtection])
            } catch let error {
                print ("error \(error)")
            }
        }
    }

    /// write string to file, does not overwrite an existing file
    func writeStringsToFile(containing: String, to directory: FileManager.SearchPathDirectory, withName name: String, withSubDirectoryPath subDirectories: String = "") -> Bool
    {
        let data = containing.data(using: .utf8)
        return writeDataToFile(containing: data, to: directory, withName: name, withSubDirectoryPath: subDirectories)
    }
    
    /// writes data to a file, if it does not already exist
    func writeDataToFile(containing: Data?, to directory: FileManager.SearchPathDirectory, withName name: String, withSubDirectoryPath subDirectories: String = "") -> Bool
    {
        let created = createFile(withData: containing, withName: name, toDirectory: directory, withSubDirectoryPath: subDirectories)
        if !created {
            let urls = fileManager.urls(for: directory, in: .userDomainMask)
            if var applicationSupportURL = urls.last {
                do{
                    for subDir in subDirectories.components(separatedBy: "/") {
                        applicationSupportURL = applicationSupportURL.appendingPathComponent(subDir, isDirectory: true)
                    }
                    
                    if exists(file: applicationSupportURL) {
                        print ("File already exists")
                        return false
                    }
                }
            }
        }
        return created
    }
    
    /// Creates a new file, does not overwrite an existing file
    func createFile(withData data: Data?, withName name: String, toDirectory directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,  withSubDirectoryPath subDirectories: String = "") -> Bool {
        if let destPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true).first {
            var fullDestPath = URL(fileURLWithPath: destPath + "/")
            
            for subDir in subDirectories.components(separatedBy: "/") {
                fullDestPath = fullDestPath.appendingPathComponent(subDir)
            }
            
            if !directoryExistsAtURL(fullDestPath) {
                _ = createDirectory(toDirectory: directory, withSubDirectoryPath: subDirectories)
            }
            
            let newFile = fullDestPath.appendingPathComponent(name).path
                if(!fileManager.fileExists(atPath:newFile)){
                    return fileManager.createFile(atPath: newFile, contents: data, attributes: nil)
                } else {
                    print("File is already created, or other error")
                    return false
                }
        }
        return false
    }
    
}



struct AppFileManager: AppFolderManipulation {

}

struct AppFile: AppFileManipulation {

    

}
