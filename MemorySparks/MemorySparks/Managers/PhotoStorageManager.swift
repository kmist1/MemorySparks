//
//  PhotoStorageManager.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//


import UIKit
import Photos

class PhotoStorageManager {
    static let shared = PhotoStorageManager()
    
    private let fileManager = FileManager.default
    private var photosDirectory: URL {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let directory = urls[0].appendingPathComponent(AppConstants.photosDirectory)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        return directory
    }
    
    func savePhoto(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }
    
    func loadPhoto(filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func deletePhoto(filename: String) -> Bool {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            print("Failed to delete photo: \(error)")
            return false
        }
    }
    
    func getTotalStorageSize() -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
}