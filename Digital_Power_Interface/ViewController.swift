//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

import Cocoa

 public var lastDataRead = Data.init(count:64)

class ViewController: NSViewController
{
   
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var teensy = usb_teensy()
   
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start_Knopf: NSButton!
   @IBOutlet weak var Stop_Knopf: NSButton!
   @IBOutlet weak var Send_Knopf: NSButton!
   
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   @IBOutlet weak var USB_OK: NSOutlineView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!

   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   @IBOutlet weak var setU_Feld: NSTextField!
   @IBOutlet weak var setU_Slider: NSSlider!
   @IBOutlet weak var U_Feld: NSTextField!
   @IBOutlet weak var setI_Feld: NSTextField!
   @IBOutlet weak var I_Feld: NSTextField!
   @IBOutlet weak var setI_Slider: NSSlider!

   var formatter = NumberFormatter()
   
   // const fuer USB
   let SET_U:UInt8 = 0xA1
   let SET_I:UInt8 = 0xB1
   let GET_U:UInt8 = 0xA2
   let GET_I:UInt8 = 0xB2
   
   
  
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      _ = Hello()
 
      formatter.maximumFractionDigits = 3
      formatter.minimumFractionDigits = 3
       formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down

      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
   }
   
   @objc func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
      var ii = 0
      while ii < 10
      {
         //print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
      
      let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      U_Feld.intValue = u
      let info = notification.userInfo
      
      //print("info: \(String(describing: info))")
      //print("new Data")
      let data = notification.userInfo?["data"]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      while i < 10
      {
         //print("i: \(i)  wert: \(lastDataRead[i])\t")
         i = i+1
      }

      if let d = notification.userInfo!["usbdata"]
      {
            
         //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,... 
         let t = type(of:d)
         //print("typ: \(t)\n") // typ: Array<UInt8>
         
         //print("element: \(d[1])\n")
         
         
         //print("d as string: \(String(describing: d))\n")
         if d != nil
         {
            //print("d not nil\n")
            var i = 0
            while i < 10
            {
               //print("i: \(i)  wert: \(d![i])\t")
               i = i+1
            }
            
         }
        
         
         //print("dic end\n")
      }
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")

   }
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   @IBAction func report_U_Slider(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_U // Code 
      print("report_U_Slider IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let u = pos / Float(sender.maxValue) * 5.12
      let Ustring = formatter.string(from: NSNumber(value: u))
      print("report_U_Slider u: \(u) Ustring: \(Ustring ?? "0")")
      setU_Feld.stringValue  = Ustring!
      let intpos = sender.intValue 
      print("report_U_Slider")
      teensy.write_byteArray[4] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[5] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_set_U(_ sender: AnyObject)
   {
      teensy.write_byteArray[0] = SET_U // Code 
      
      // senden mit faktor 1000
      //let u = setU_Feld.floatValue 
      let U = setU_Feld.floatValue * 1000
      let intU = UInt(U)
      
      let U_HI = (intU & 0xFF00) >> 8
      let U_LO = intU & 0x00FF
      //let U_LO = U * 1000 - 1000 * Float(U_HI)
      print("report_set_U U: \(U) U HI: \(U_HI) U LO: \(U_LO) ")
      
      teensy.write_byteArray[2] = UInt8(U_LO)
      teensy.write_byteArray[3] = UInt8(U_HI)
      
       if (usbstatus > 0)
       {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_U U: %d",senderfolg)
         }
      }
   }

   @IBAction func report_set_I(_ sender: AnyObject)
   {
      
   }

   
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         teensy.start_read_USB(true)
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true

      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false

      }
      
      //teensy.start_teensy_Timer()
      
      //     var somethingToPass = "It worked"
      
      //      let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tester:"), userInfo: somethingToPass, repeats: true)
      
   }
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      let erfolg = teensy.USBOpen()
      usbstatus = erfolg
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
         print("status 1")
         USB_OK.backgroundColor = NSColor.green
         print("USB-Device da")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist da"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()

         let manu = get_manu()
         //println(manu) // ok, Zahl
//         var manustring = UnsafePointer<CUnsignedChar>(manu)
         //println(manustring) // ok, Zahl
         
         let manufactorername = String(cString: UnsafePointer(manu!))
         print("str: %s", manufactorername)
         manufactorer.stringValue = manufactorername
         
         //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         Start_Knopf.isEnabled = true
         Send_Knopf.isEnabled = true
      }
      else
         
      {
         print("status 0")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         
         if let taste = USB_OK
         {
            print("Taste USB_OK ist nicht nil")
            taste.backgroundColor = NSColor.red
         //USB_OK.backgroundColor = NSColor.redColor()
            
         }
         else
         {
            print("Taste USB_OK ist nil")
         }
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
         Send_Knopf.isEnabled = false
         return
      }
      print("antwort: \(teensy.status())")
   }
   
   @IBAction func report_stop_read_USB(_ sender: AnyObject)
   {
      teensy.read_OK = false
      if teensy.dev_present() > 0
      {
         Start_Knopf.isEnabled = true
         Send_Knopf.isEnabled = true
      }
      else
      {
         Start_Knopf.isEnabled = false
      }
      Stop_Knopf.isEnabled = false

   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      if teensy.dev_present() > 0
      {
         var senderfolg = teensy.send_USB()
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Send_Knopf.isEnabled = false

      }
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("send_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      Anzeige.stringValue = "not OK"
      println("kein USB-Device")
      }
      else
      {
      usbstatus = 1
      println("USB-Device da")
      var manu = get_manu()
      //println(manu) // ok, Zahl
      var manustring = UnsafePointer<CUnsignedChar>(manu)
      //println(manustring) // ok, Zahl
      
      let manufactorername = String.fromCString(UnsafePointer(manu))
      println("str: %s", manufactorername!)
      manufactorer.stringValue = manufactorername!
      
      /*
      var strA = ""
      strA.append(Character("d"))
      strA.append(UnicodeScalar("e"))
      println(strA)
      
      let x = manu
      let s = "manufactorer"
      println("The \(s) is \(manu)")
      var pi = 3.14159
      NSLog("PI: %.7f", pi)
      let avgTemp = 66.844322156
      println(NSString(format:"AAA: %.2f", avgTemp))
      */
      }
      */
      
   }
   
   override var representedObject: Any? {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   
}

