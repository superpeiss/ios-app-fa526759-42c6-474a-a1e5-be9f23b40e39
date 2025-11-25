import SwiftUI
import SceneKit

struct Preview3DView: View {
    @ObservedObject var viewModel: ConfiguratorViewModel
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("3D Preview")
                .font(.title2)
                .fontWeight(.bold)

            Text("Preview your configured assembly")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 3D Scene View
            ZStack {
                Scene3DView(components: viewModel.configuration.getAllComponents())
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }

            // Component List
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selected Components")
                        .font(.headline)

                    ForEach(viewModel.configuration.getAllComponents()) { component in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)

                            VStack(alignment: .leading) {
                                Text(component.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(component.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(component.priceFormatted)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct Scene3DView: UIViewRepresentable {
    let components: [Component]

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.systemGray6

        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        sceneView.scene?.rootNode.addChildNode(cameraNode)

        return sceneView
    }

    func updateUIView(_ sceneView: SCNView, context: Context) {
        // Clear existing nodes
        sceneView.scene?.rootNode.childNodes.forEach { node in
            if node.camera == nil {
                node.removeFromParentNode()
            }
        }

        // Add component models
        createAssembly(in: sceneView.scene!, components: components)
    }

    private func createAssembly(in scene: SCNScene, components: [Component]) {
        var yOffset: Float = 0

        for (index, component) in components.enumerated() {
            let node = createNodeForComponent(component, index: index)
            node.position = SCNVector3(x: 0, y: yOffset, z: 0)
            scene.rootNode.addChildNode(node)

            yOffset += 2.5 // Stack components vertically
        }
    }

    private func createNodeForComponent(_ component: Component, index: Int) -> SCNNode {
        let geometry: SCNGeometry

        switch component.category {
        case .baseUnit:
            geometry = SCNBox(width: 4, height: 1, length: 3, chamferRadius: 0.1)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemBlue

        case .motor:
            geometry = SCNCylinder(radius: 1, height: 2)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemRed

        case .gearbox:
            geometry = SCNBox(width: 2, height: 1.5, length: 2, chamferRadius: 0.1)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen

        case .controller:
            geometry = SCNBox(width: 1.5, height: 0.5, length: 2, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemOrange

        case .sensor:
            geometry = SCNCylinder(radius: 0.3, height: 0.5)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemPurple

        case .housing:
            geometry = SCNBox(width: 5, height: 3, length: 4, chamferRadius: 0.2)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGray.withAlphaComponent(0.3)

        case .connector:
            geometry = SCNSphere(radius: 0.3)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemYellow

        case .mounting:
            geometry = SCNTorus(ringRadius: 1, pipeRadius: 0.2)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemBrown
        }

        // Add metallic effect
        geometry.firstMaterial?.metalness.contents = 0.5
        geometry.firstMaterial?.roughness.contents = 0.2

        let node = SCNNode(geometry: geometry)

        // Add label
        let textGeometry = SCNText(string: component.category.rawValue, extrusionDepth: 0.1)
        textGeometry.font = UIFont.systemFont(ofSize: 0.3)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.1, 0.1, 0.1)
        textNode.position = SCNVector3(-1, 1, 0)

        node.addChildNode(textNode)

        // Add rotation animation
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 10)
        let repeatRotation = SCNAction.repeatForever(rotation)
        node.runAction(repeatRotation)

        return node
    }
}

#Preview {
    Preview3DView(viewModel: ConfiguratorViewModel())
}
