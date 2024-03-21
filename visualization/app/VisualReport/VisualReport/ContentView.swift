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
    
    var nameView: some View {
        VStack {
            ForEach(allFileNames, id: \.self) { name in
                Button(
                    action: {
                        readData(filePath: allFilePaths[name] ?? "")
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
        VStack {
//            BarChartView(
//                viewModel: BarChartViewModel(
//                    xAxisName: "time",
//                    yAxisName: "price",
//                    isInline: true,
//                    barChartData: BarChartData.dummyList
//                )
//            )
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
    
    func readData(filePath: String) {
        do {
            let csvFile: CSV = try CSV<Named>(url: URL(fileURLWithPath: filePath))
            print(csvFile.columns?.count)
        } catch {
            print("ERROR: \(error)")
        }
    }
}
