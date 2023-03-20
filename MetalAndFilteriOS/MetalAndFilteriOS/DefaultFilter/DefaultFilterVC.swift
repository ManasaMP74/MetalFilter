//
//  DefaultFilterVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 08/03/23.
//

import UIKit
import CoreImage

class DefaultFilterVC: UIViewController {
    var imageView = UIImageView()
    var intensity = UISlider()
    var filterButton = UIButton()
    
    var currentImage = UIImage(named: "1")
    var context: CIContext!
    var currentFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        addConstraints()
        intensity.addTarget(self, action: #selector(intensityChanged(_:)), for: .valueChanged)
        filterButton.addTarget(self, action: #selector(changeFilter(_:)), for: .touchUpInside)
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        let ciImage = CIImage(image: currentImage!)
        currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @objc func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        currentFilter = CIFilter(name: actionTitle)
        let beginImage = CIImage(image: currentImage!)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @objc func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        //not all filters have an intensity setting. If you try this using the CIBumpDistortion filter, the app will crash because it doesn't know what to do with a setting for the key kCIInputIntensityKey.
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage!.size.width / 2, y: currentImage!.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgImage = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    func addConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        intensity.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(intensity)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        filterButton.setTitle("Change Filter", for: .normal)
        filterButton.setTitleColor(UIColor.red, for: .normal)
        filterButton.backgroundColor = UIColor.lightGray
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            intensity.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            intensity.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            intensity.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            intensity.heightAnchor.constraint(equalToConstant: 50),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
