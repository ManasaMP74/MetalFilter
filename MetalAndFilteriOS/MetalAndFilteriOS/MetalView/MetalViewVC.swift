//
//  MetalVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import UIKit
import MetalKit

class MetalViewVC: UIViewController {
    let metalView = MTKView()
    var renderer: MetalRender?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        renderer = MetalRender(metalView: metalView)
    }
}
