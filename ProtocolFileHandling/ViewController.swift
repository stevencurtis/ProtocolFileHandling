//
//  ViewController.swift
//  ProtocolFileHandling
//
//  Created by Steven Curtis on 09/10/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AppFileManager().prepareSearchPathDirectories()
        
        AppFileManager().createDirectory(toDirectory: .applicationSupportDirectory)
        
        let file = AppFile()
//        _ = file.writeStringsToFile(containing: "TestText to be written 2", to: .applicationSupportDirectory, withName: "test.txt")
        
        print(
        AppFileManager().directoryExistsAtPath("")
        )
        
        _ = file.writeStringsToFile(containing: "TestText to be written 2", to: .applicationSupportDirectory, withName: "test.txt", withSubDirectoryPath: "a/b")
        
        
        // file.copyFile(withOriginName: "test.txt", withOriginSubDirectoryPath: "a/b", withDestinationName: "testCopy.txt", withDestinationSubDirectoryPath: "a")
        
        // file.copyFileAtomically(withOriginFileName: "test.txt", withOriginSubDirectoryPath: "a/b", withDestinationSubDirectoryPath: "a", originDirectory: .applicationSupportDirectory, destinationDirectory: .applicationSupportDirectory)
        
        
        file.moveFileAtomically(withOriginFileName: "test.txt", withOriginSubDirectoryPath: "a/b", withDestinationSubDirectoryPath: "a", originDirectory: .applicationSupportDirectory, destinationDirectory: .applicationSupportDirectory)
        
        // AppFileManager().removeDirectory(toDirectory: .applicationSupportDirectory, withSubDirectoryPath: "a/b")
        
//        AppFileManager().removeDirectory(toDirectory: .applicationSupportDirectory)
        
        
//        let firstData = "Test Data".data(using: .utf8)

        //        file.createFileFromDataAtomically(withData: firstData, withName: "TestData.txt")
        

    }


}

