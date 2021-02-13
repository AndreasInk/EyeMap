//
//  CustomARView.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import SwiftUI
import RealityKit
import ARKit

var camera = Entity()
class CustomARView: ARView {
    // Referring to @EnvironmentObject
    var saveLoadState: SaveLoadState
    var arState: ARState
    var distances = [SIMD3<Float>]()
    var anchorz = [ARAnchor]()
    var transformations = [Transform]()
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        return configuration
    }
    // MARK: - Init and setup
    
    init(frame frameRect: CGRect, saveLoadState: SaveLoadState, arState: ARState) {
        self.saveLoadState = saveLoadState
        self.arState = arState
        super.init(frame: frameRect)
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func setup() {
        self.session.run(defaultConfiguration)
        self.session.delegate = self
        self.setupGestures()
        self.debugOptions = [ .showFeaturePoints ]
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            camera.position = self.cameraTransform.translation
        }
    }
    
    // MARK: - AR content
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
    var virtualObject = AssetModel(name: "teapot.usdz")
    
    
    // MARK: - AR session management
    var isRelocalizingMap = false
    
 
    // MARK: - Persistence: Saving and Loading
    let storedData = UserDefaults.standard
    let mapKey = "ar.worldmap"

    lazy var worldMapData: Data? = {
        storedData.data(forKey: mapKey)
    }()
    
    func resetTracking() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        self.isRelocalizingMap = false
        self.virtualObjectAnchor = nil
    }
}
