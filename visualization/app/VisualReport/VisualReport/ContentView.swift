//
//  ContentView.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 21/3/2567 BE.
//

import SwiftCSV
import SwiftUI

struct ContentView: View {
    
    @State var filename: String = ""
    @State var folderPath = ""
    @State var allFilePaths = [String : String]()
    @State var allFileNames = [String]()
    @State var shouldShowCsvData = false
    // NAVIGATION
    @State private var csvData: CSVDataModel? = nil
    @State private var navigationPath = NavigationPath()
    
    var nameView: some View {
        VStack {
            ForEach(allFileNames, id: \.self) { name in
                Button(
                    action: {
                        guard let filePath = allFilePaths[name] else {
                            return
                        }
                        if filePath.hasSuffix(".csv") {
                            if let csvData = readCSVData(filePath: filePath) {
                                navigationPath.append(csvData)
                            }
                        } else {
                            readTxtData(filePath: filePath)
                        }
                    },
                    label: {
                        Text(name)
                    }
                )
                .buttonStyle(.link)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            VStack {
                if allFileNames.isEmpty {
                    Button(
                        action: {
                            getPermission()
                        },
                        label: {
                            Text("Get Folder Permission")
                        }
                    )
                }
                nameView
            }
            .navigationDestination(for: CSVDataModel.self) { data in
                ProductSelectionScreen(viewModel: ProductSelectionViewModel(csvData: data))
            }
        }
    }
    
    func getPermission() {
        let panel = NSOpenPanel()
        // Sets up so user can only select a single directory
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = false
        panel.title = "Select Directory"
        panel.prompt = "Select Directory"
        
        let response = panel.runModal()
        if response == .OK {
            if let panelURL = panel.url { // This is a directory url
                print(panelURL.path())
                folderPath = panelURL.path()
                saveAllFilePath(basePath: folderPath)
            }
        }
    }
    
    func saveAllFilePath(basePath: String) {
        let fm = FileManager.default
        do {
            let subFolders = try fm.contentsOfDirectory(atPath: folderPath)
            for folderName in subFolders {
                if !folderName.contains(".") {
                    let filePath = "\(folderPath)\(folderName)"
                    let fileNames = try fm.contentsOfDirectory(atPath: filePath)
                    for name in fileNames {
                        allFileNames.append(name)
                        allFilePaths[name] = "\(filePath)/\(name)"
                    }
                }
            }
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    func readTxtData(filePath: String) {
        do {
            // Read the contents of the file
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            var contentArray = fileContents.components(separatedBy: "\n")
            contentArray = contentArray.sorted()
            // Print the contents of the file
            let writeFilePath = folderPath+"word/BengaliSortedWords.txt"
            print(writeFilePath)
            do {
                // Write the text content to the file
                let contentToWrite = contentArray.joined(separator: "\n")
                try contentToWrite.write(toFile: writeFilePath, atomically: true, encoding: .utf8)
                
                print("Data has been successfully written to \(writeFilePath)")
            } catch {
                // Handle error if writing fails
                print("Error writing data to \(writeFilePath):", error)
            }
        } catch {
            // Handle any errors that occur during file reading
            print("Error reading contents of \(filePath):", error)
        }
    }
    
    func readCSVData(filePath: String) -> CSVDataModel? {
        let (data, error) = CSVFileReader().readCSVFile(filePath: filePath)
        guard error == nil else {
            return nil
        }
        return data
    }
}
