//
//  CameraViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 24.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate: class {
    
    func scannerDidFinishWithResult(_ result: String)
    func scannerDidFinishWithError(_ error: String?)
}


class CameraViewController: BaseViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var cameraFrameImage: UIImageView!
    
    private var captureSession = AVCaptureSession()
    private let supportedCodeTypes: [AVMetadataObject.ObjectType] = [.qr]
    private var didFoundCodeFlag = false
    
    weak var delegate: QRCodeScannerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsNavBar(title: "SCAN_QR_CODE".localized(), rightButtonImage: #imageLiteral(resourceName: "flash"), rightButtonSelector: #selector(flashAction))
        
        setupCamera()
    }
    

    @objc func flashAction() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                setRightIcon(#imageLiteral(resourceName: "flash"))
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    setRightIcon(#imageLiteral(resourceName: "flash-solid"))
                } catch {
                    print(error)
                }
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateOverlayMask()
    }
    
    private func updateOverlayMask() {
        let overlayMask = CAShapeLayer()
        overlayMask.frame = overlayView.bounds
        overlayMask.fillColor = UIColor.black.cgColor
        
        let side = UIScreen.main.bounds.width - 166
        let x = view.center.x - side/2
        let y = view.center.y - side/2 - 50
        let scanZoneFrame = CGRect.init(x: x, y: y, width: side, height: side)
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let innerPath = UIBezierPath(roundedRect: scanZoneFrame, cornerRadius: 12).reversing()
        
        path.append(innerPath)
        
        overlayMask.path = path.cgPath
        
        overlayView.layer.mask = nil
        overlayView.layer.mask = overlayMask
        
        view.bringSubviewToFront(cameraFrameImage)
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            #if DEBUG
                print("No capture device found")
            #endif
            scannerDidFinishWithError(nil)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer)
            
            captureSession.startRunning()
        } catch {
            scannerDidFinishWithError(error)
            return
        }
    }
    
    private func scannerDidFinishWithResult(_ result: String) {
        guard !didFoundCodeFlag else {
            return
        }
        
        self.view.isUserInteractionEnabled = false
        self.didFoundCodeFlag = true
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(1103)
        self.captureSession.stopRunning()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.delegate?.scannerDidFinishWithResult(result)
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    private func scannerDidFinishWithError(_ error: Error?) {
        let errorMessage = error?.localizedDescription
        
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.captureSession.stopRunning()
            
            self.delegate?.scannerDidFinishWithError(errorMessage)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            // No metadata received
            return
        }
        
        for metaData in metadataObjects {
            guard let metadataObj = (metaData as? AVMetadataMachineReadableCodeObject),
                supportedCodeTypes.contains(metadataObj.type),
                let result = metadataObj.stringValue,
                !result.isEmpty else {
                    continue
            }
            
            scannerDidFinishWithResult(result)
            break
        }
    }
}
