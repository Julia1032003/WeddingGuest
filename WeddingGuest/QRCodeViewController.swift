//
//  QRCodeViewController.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/6/28.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    
    var captureSesion:AVCaptureSession?
    var previewLayer:AVCaptureVideoPreviewLayer!
    var QRCodeString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //按鈕圓角設定
        checkInButton.layer.cornerRadius = 10.0
        checkInButton.layer.masksToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(captureSesion?.isRunning == false){
            captureSesion?.startRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         setQRCodeScan()
        
    }
    
    //掃QRCode的動作
    func setQRCodeScan(){
        
        //實體化一個AVCaptureSession物件
        captureSesion = AVCaptureSession()
        
        //AVCaptureDevice可以抓到相機和其屬性
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return}
        let videoInput:AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }catch let error {
            print(error)
            return
        }
        if (captureSesion?.canAddInput(videoInput) ?? false ){
            captureSesion?.addInput(videoInput)
        }else{
            return
        }
        
        //AVCaptureMetaDataOutput輸出影音資料，先實體化AVCaptureMetaDataOutput物件
        let metaDataOutput = AVCaptureMetadataOutput()
        if (captureSesion?.canAddOutput(metaDataOutput) ?? false){
            captureSesion?.addOutput(metaDataOutput)
            
            //關鍵！執行處理QRCode
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //metadataOutput.metadataObjectTypes表示要處理哪些類型的資料，處理QRCODE
            metaDataOutput.metadataObjectTypes = [.qr, .ean8 , .ean13 , .pdf417]
            
        }else{
            return
        }
        
        //用AVCaptureVideoPreviewLayer來呈現Session上的資料
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion!)
        //顯示size
        previewLayer.videoGravity = .resizeAspectFill
        //呈現在camView上面
        previewLayer.frame = camView.layer.frame
        //加入畫面
        view.layer.addSublayer(previewLayer)
        
        //顯示scan Area window 框框
        let size = 300
        let sWidth = Int(view.frame.size.width)
        let xPos = (sWidth/2)-(size/2)
        let scanRect = CGRect(x: CGFloat(xPos), y: 150 , width: CGFloat(size) , height: CGFloat(size))
        //設定scan Area window 框框
        let scanAreaView = UIView()
        scanAreaView.layer.borderColor = UIColor.gray.cgColor
        scanAreaView.layer.borderWidth = 2
        scanAreaView.frame = scanRect
        view.addSubview(scanAreaView)
        view.bringSubviewToFront(scanAreaView)
        
        DispatchQueue.main.async(execute: {
            
            //開始影像擷取呈現鏡頭的畫面
            self.captureSesion?.startRunning()
        })
         
    }
    
    //使用AVCaptureMetadataOutput物件辨識QR Code，此AVCaptureMetadataOutputObjectsDelegate的委派方法metadataOutout會被呼叫
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSesion?.startRunning()
        if let metadataObject = metadataObjects.first{
            
            //AVMetadataMachineReadableCodeObject是從OutPut擷取到barcode內容
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {return}
            //將讀取到的內容轉成string
            guard let stringValue = readableObject.stringValue else {return}
            //掃到QRCode後的震動提示
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //將string資料放到label元件上
            infoLabel.text = stringValue
            //存取QRcodeURL
            QRCodeString = stringValue
            
        }
    }
    
    //畫面不顯示即停止掃描
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(captureSesion?.isRunning == true){
            captureSesion?.stopRunning()
        }
    }
    
    
    @IBAction func checkInBtn(_ sender: Any) {
        
           //利用通知傳值至上一頁
        let notificationName = Notification.Name("GetQrStr")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["guestQRStr":self.QRCodeString!])
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
