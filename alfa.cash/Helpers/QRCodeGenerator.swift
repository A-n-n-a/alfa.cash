//
//  QRCodeGenerator.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 21.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

final class QRCodeGenerator {
    func generate(from dataString: String?,
                  scale: CGFloat = Constants.QRCode.defaultScale) -> UIImage? {
        guard let info = dataString else {
            return nil
        }
        
        if let qrCodeData = info.data(using: .isoLatin1) {
        
            return getQrFrom(qrCodeData: qrCodeData, scale: scale)
        }
        
        return nil
    }
    
    func generate(from url: URL,
                  scale: CGFloat = Constants.QRCode.defaultScale) -> UIImage? {
        guard let qrCodeData = try? Data.init(contentsOf: url) else {
            return nil
        }
        
        return getQrFrom(qrCodeData: qrCodeData, scale: scale)
    }
    
    private func getQrFrom(qrCodeData: Data, scale: CGFloat) -> UIImage? {
        let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator")
        qrCodeFilter?.setValue(qrCodeData, forKey: "inputMessage")
        qrCodeFilter?.setValue(Constants.QRCode.inputCorrectionLevel,
                               forKey: "inputCorrectionLevel")
        
        guard let qrCodeImage = qrCodeFilter?.outputImage else {
            return nil
        }
        
        let imageSize = qrCodeImage.extent.integral
        let outputSize = CGSize(width: scale, height: scale)
        
        let transform = CGAffineTransform(scaleX: outputSize.width / imageSize.width,
                                          y: outputSize.height / imageSize.height)
        
        let imageByTransform = qrCodeImage.transformed(by: transform)
        
        let colorParameters = [
            "inputColor0": CIColor(color: .black), // Foreground
            "inputColor1": CIColor(color: .white) // Background
        ]
        let colored = imageByTransform.applyingFilter("CIFalseColor", parameters: colorParameters)
        
        let context = CIContext(options: nil)
        guard let cgImageRef = context.createCGImage(colored, from: imageByTransform.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImageRef)
    }
}
