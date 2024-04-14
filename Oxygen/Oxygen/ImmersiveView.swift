//
//  ImmersiveView.swift
//  Oxygen
//
//  Created by George Kim on 2/3/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            guard let skyboxEntity = createSkybox() else {
                print("Error loading skybox entity")
                return
            }
            
            content.add(skyboxEntity)
        }
    }
    
    private func createSkybox () -> Entity? {
        let largeSphere = MeshResource.generateSphere(radius: 100)
        
        var skyboxMaterial = UnlitMaterial()
        
        do {
            // Replace the file name of your skybox texture here.
            let texture = try TextureResource.load(named: "ImmersiveBackground")
            skyboxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Error loading texture: \(error)")
        }
        
        let skyboxEntity = Entity()
        skyboxEntity.components.set(ModelComponent(mesh: largeSphere, materials: [skyboxMaterial]))
        
        skyboxEntity.scale *= .init(x: -1, y: 1, z: 1)
        
        return skyboxEntity
    }
}
