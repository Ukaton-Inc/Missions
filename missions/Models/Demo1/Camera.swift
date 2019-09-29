//
//  Camera.swift
//  missions
//
//  Created by Umar Qattan on 9/7/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation
import AVFoundation

enum CameraEffect: Int {
    case zoom = 0
    case lens = 1
}

class Camera {
    
    private var captureSession: AVCaptureSession?
    private var captureDevice: AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    init() {
        self.captureDevice = AVCaptureDevice.default(for: .video)
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer()
    }
    
    func setupSession() {
        self.captureSession = AVCaptureSession()
        do {
            guard let captureDevice = self.captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            self.captureSession?.addInput(input)
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer(_ bounds: CGRect) {
        guard let captureSession = self.captureSession else { return }
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.frame = bounds
    }
    
    func startRunning() {
        self.captureSession?.startRunning()
    }
    
    func stopRunning() {
        self.captureSession?.stopRunning()
    }
    
    func updateZoomFactor(_ values: [Int]) {
        guard let device = self.captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.videoZoomFactor = self.getFactor(cameraEffect: .zoom, values: values)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func updateLensFactor(_ values: [Int]) {
        guard let device = self.captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.setFocusModeLocked(
                lensPosition: Float(self.getFactor(cameraEffect: .lens, values: values)),
                completionHandler: nil
            )
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        guard let device = self.captureDevice else { return 0 }
        return min(min(max(factor, self.minimumZoom), self.maximumZoom), device.activeFormat.videoMaxZoomFactor)
    }
    
    private func getFactor(cameraEffect: CameraEffect, values: [Int]) -> CGFloat {
        let values_ = values.map({map(minRange: 0, maxRange: 255, minDomain: 0, maxDomain: 100, value: $0)})
        
        print("values: \(values_)")
        let topSensors = [0, 1, 3]
        let bottomSensors = [2, 4, 5]
        
        var topSum: CGFloat = 1
        var bottomSum: CGFloat = 1
        
        for i in topSensors {
            topSum += CGFloat(values_[i])
        }
        
        for j in bottomSensors {
            bottomSum += CGFloat(values_[j])
        }
        
        switch cameraEffect {
        case .zoom:
            let value = topSum * topSum / (bottomSum * (topSum + bottomSum))

            return self.minMaxZoom(value)
        case .lens:
            return topSum / (topSum + bottomSum)
        }
    }
}
