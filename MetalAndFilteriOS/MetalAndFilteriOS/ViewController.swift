//
//  ViewController.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 08/03/23.
//

import UIKit

class ViewController: UIViewController {
    let array = ["defaultFilter", "MetalFilterBasic", "TraingleWithGeneralFile", "CubeIn2D", "CubeScaling", "Cube3DWithoutViewTransition", "Cube3DWithViewTransition", "Cube3DWithPerformance", "CubeWithLight", "MetalViewVC", "OpenglSquare", "CubeWithTexture", "CustomFilterByMetal"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = DefaultFilterVC()
            navigationController?.pushViewController(vc, animated: false)
        case 1:
            let vc = MetalFilterVC()
            navigationController?.pushViewController(vc, animated: false)
        case 2:
            let vc = TraingleVC()
            navigationController?.pushViewController(vc, animated: false)
        case 3:
            let vc = CubeVC()
            navigationController?.pushViewController(vc, animated: false)
        case 4:
            let vc = CubeScalingVC()
            navigationController?.pushViewController(vc, animated: false)
        case 5:
            let vc = Cube3DVC()
            navigationController?.pushViewController(vc, animated: false)
        case 6:
            let vc = Cube3dVCWithViewTransition()
            navigationController?.pushViewController(vc, animated: false)
        case 7:
            let vc = Cube3DVCWithPerformance()
            navigationController?.pushViewController(vc, animated: false)
        case 8:
            let vc = CubeLightVC()
            navigationController?.pushViewController(vc, animated: false)
        case 9:
            let vc = MetalViewVC()
            navigationController?.pushViewController(vc, animated: false)
        case 10:
            let vc = OpenglSquareVC()
            navigationController?.pushViewController(vc, animated: false)
        case 11:
            let vc = CubeTextureVC()
            navigationController?.pushViewController(vc, animated: false)
        case 11:
            let vc = CustomFilterByMetalVC()
            navigationController?.pushViewController(vc, animated: false)
        default:
            break
        }
    }
}
