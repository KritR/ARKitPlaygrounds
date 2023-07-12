import SwiftUI
import ARKit
import Photos

struct ARViewContainer: UIViewRepresentable {
    @Binding var takePhoto: Bool
    typealias UIViewType = ARSCNView
    @Binding var unset: Bool

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.scene.rootNode.camera?.wantsExposureAdaptation = false
        arView.scene.rootNode.camera?.exposureOffset = 0
        
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let configuration = ARWorldTrackingConfiguration()
        
        if (unset)
        {
            if #available(iOS 16.0, *) {
                if let device = ARWorldTrackingConfiguration.configurableCaptureDeviceForPrimaryCamera {
                    do {
                        try device.lockForConfiguration ()
                        
                        // Specify your custom parameters here.
                        let duration = AVCaptureDevice.currentExposureDuration
                        let iso = AVCaptureDevice.currentISO
                        
                        // The completion handler to be called once the setting has been applied.
                        let completionHandler: (CMTime) -> Void = { time in
                            print("Exposure setting has been set.")
                        }
                        
                        
                        // Use setExposureModeCustom to apply these settings.
                        device.setExposureModeCustom(duration: CMTime(seconds: duration.seconds * 3, preferredTimescale: duration.timescale) , iso: iso.advanced(by: 0.3), completionHandler: completionHandler)
                        // configuration your focus mode
                        // you need to change  ARWorldTrackingConfiguration().isAutoFocusEnabled at the same time
                        
                        device.unlockForConfiguration ()
                    } catch {
                        
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            unset = false
        }

        
        uiView.session.run(configuration, options: [])
        if self.takePhoto {
            
            let image = uiView.snapshot()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.takePhoto = false
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let sceneView = renderer as? ARSCNView else { return }
            guard let frame = sceneView.session.currentFrame else { return }
            
            
            let intrinsics = frame.camera.intrinsics
            print("Intrinsics: \(intrinsics)")
            
            // Let's take a pixel position (u, v)
            let u: Float = 100
            let v: Float = 200
            
            // Convert pixel to angles
            let angles = pixelToAngle(u: u, v: v, intrinsics: intrinsics)
            print("Angles: \(angles)")
        }

        func pixelToAngle(u: Float, v: Float, intrinsics: matrix_float3x3) -> (Float, Float) {
            let fx = intrinsics[0, 0]
            let fy = intrinsics[1, 1]
            let cx = intrinsics[2, 0]
            let cy = intrinsics[2, 1]

            let thetaX = atan2(u - cx, fx)
            let thetaY = atan2(v - cy, fy)

            return (thetaX, thetaY)
        }
    }
}
