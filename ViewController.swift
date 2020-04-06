//
//  ViewController.swift
//  Webcam2
//
//  Created by Connor T on 4/6/20.
//  Copyright © 2020 Connor T. All rights reserved.
//

import AVFoundation
import UIKit
import HaishinKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var boundText: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var rtmpConnection: RTMPConnection!
    var rtmpStream: RTMPStream!
    
    var isBackCam = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rtmpConnection = RTMPConnection()
        self.rtmpStream = RTMPStream(connection: rtmpConnection)
        // Do any additional setup after loading the view.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                return
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    return
                }
            
            case .denied: // The user has previously denied access.
                return

            case .restricted: // The user can't grant access due to restrictions.
                return
        }
    }
    
    @IBAction func actualButtonPress(_ sender: UIButton) {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync {
                self.rtmpStream.captureSettings = [
                    .fps: 60, // FPS
                    .sessionPreset: AVCaptureSession.Preset.hd1920x1080, // input video width/height
                ]
                
                self.rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio))
                self.rtmpStream.attachCamera(DeviceUtil.device(withPosition: self.isBackCam ? .back : .front))

                let hkView = HKView(frame: self.boundText.frame)
                hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
                hkView.attachStream(self.rtmpStream)

                // add ViewController#view
                self.view.addSubview(hkView)

                self.rtmpConnection.connect("RTMPURL")
                self.rtmpStream.publish("webcam")
            }
        })
    }
    
    @IBAction func camButtonPressed(_ sender: UIButton) {
        isBackCam = !isBackCam
        self.rtmpStream.attachCamera(DeviceUtil.device(withPosition: isBackCam ? .back : .front))
        sender.setTitle(isBackCam ? "Front Cam" : "Back Cam", for: UIControl.State.normal)
    }
}

