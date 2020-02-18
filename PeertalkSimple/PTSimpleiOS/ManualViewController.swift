//
//  ViewController.swift
//  PeertalkManual-iOS
//
//  Created by Kiran Kunigiri on 1/7/17.
//  Copyright © 2017 Kiran. All rights reserved.
//

import UIKit

class ManualViewController: UIViewController {

    // Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    // Properties
    weak var serverChannel: PTChannel?
    weak var peerChannel: PTChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a channel and start listening
        let channel = PTChannel(delegate: self)
        
        // Create a custom port number that the connection will use. I have declared it in the Helper.swift file
        // Make sure the Mac app uses the same number. Any 4 digit integer will work fine.
        channel?.listen(onPort: in_port_t(PORT_NUMBER), iPv4Address: INADDR_LOOPBACK, callback: { (error) in
            if error != nil {
                print("ERROR (Listening to post): \(error?.localizedDescription ?? "-1")")
            } else {
                self.serverChannel = channel
            }
        })
    }
    
    // Add 1 to our counter label and send the data if the device is connected
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if isConnected() {
            // Get the new counter number
            let num = "\(Int(label.text!)! + 1)"
            self.label.text = num
            
            let data = NSKeyedArchiver.archivedData(withRootObject: num) as NSData
            self.sendData(data: data.createReferencingDispatchData(), type: PTType.number)
        }
    }
    
    /** Checks if the device is connected, and presents an alert view if it is not */
    func isConnected() -> Bool {
        if peerChannel == nil {
            let alert = UIAlertController(title: "Disconnected", message: "Please connect to a device first", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return peerChannel != nil
    }

    /** Closes the USB connectin */
    func closeConnection() {
        self.serverChannel?.close()
    }
    
    /** Sends data to the connected device */
    func sendData(data: __DispatchData, type: PTType) {
        if peerChannel != nil {
            peerChannel?.sendFrame(ofType: type.rawValue, tag: PTFrameNoTag, withPayload: data, callback: { (error) in
                print(error?.localizedDescription ?? "Sent data")
            })
        }
    }

}

// MARK: - Channel Delegate
extension ManualViewController: PTChannelDelegate {
    
    func ioFrameChannel(_ channel: PTChannel!, shouldAcceptFrameOfType type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        
        // Check if the channel is our connected channel; otherwise ignore it
        // Optional: Check the frame type and optionally reject it
        if channel != peerChannel {
            return false
        } else {
            return true
        }
    }
    
    func ioFrameChannel(_ channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        
        // Create the data objects
        let dispatchData = payload.dispatchData as DispatchData
        let data = NSData(contentsOfDispatchData: dispatchData as __DispatchData) as Data
        
        // Check frame type
        if type == PTType.number.rawValue {
            
            // The first conversion method of DispatchData (explained in the addButtonTapped method)
            // let message = String(bytes: dispatchData, encoding: .utf8)
            
            // The second, universal method of conversion (Using NSKeyedUnarchiver)
            let count = NSKeyedUnarchiver.unarchiveObject(with: data) as! Int
            
            // Update the UI
            self.label.text = "\(count)"
            
        }
    }
    
    func ioFrameChannel(_ channel: PTChannel!, didEndWithError error: Error?) {
        print("ERROR (Connection ended): \(String(describing: error?.localizedDescription))")
        self.statusLabel.text = "Status: Disconnected"
    }
    
    func ioFrameChannel(_ channel: PTChannel!, didAcceptConnection otherChannel: PTChannel!, from address: PTAddress!) {
        
        // Cancel any existing connections
        if (peerChannel != nil) {
            peerChannel?.cancel()
        }
        
        // Update the peer channel and information
        peerChannel = otherChannel
        peerChannel?.userInfo = address
        print("SUCCESS (Connected to channel)")
        self.statusLabel.text = "Status: Connected"
    }
}












