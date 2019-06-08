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
   @IBOutlet weak var Start_Read_Knopf: NSButton!
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   @IBOutlet weak var USB_OK: NSOutlineView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!

   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   @IBOutlet weak var setU_Feld: NSTextField!
   @IBOutlet weak var setU_Slider: NSSlider!
   @IBOutlet weak var setU_Stepper: NSStepper!
   @IBOutlet weak var U_Feld: NSTextField!
   
   @IBOutlet weak var setI_Feld: NSTextField!
   @IBOutlet weak var I_Feld: NSTextField!
   @IBOutlet weak var setI_Slider: NSSlider!
   @IBOutlet weak var setI_Stepper: NSStepper!

   @IBOutlet weak var setP_Feld: NSTextField!
   @IBOutlet weak var P_Feld: NSTextField!
   @IBOutlet weak var setP_Slider: NSSlider!
   

   var formatter = NumberFormatter()
   
   
   let U_START = 5000 // mV
   let I_START = 200 // mA
   
   // const fuer USB
   let SET_U:UInt8 = 0xA1
   let SET_I:UInt8 = 0xB1
   let GET_U:UInt8 = 0xA2
   let GET_I:UInt8 = 0xB2
   
   let SET_P:UInt8 = 0xA3
   let GET_P:UInt8 = 0xB3

   
   let U_DIVIDER:Float = 9.8
   let ADC_REF:Float = 3.26
   
   let U_byte_h = 4
   let U_byte_l = 5

   let I_byte_h = 6
   let I_byte_l = 7

   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      _ = Hello()
 
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
       formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down

      setU_Stepper.floatValue = setU_Feld.floatValue * 100
      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
      
      
      teensy.write_byteArray[U_byte_h] = UInt8(((U_START/10) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[U_byte_l] = UInt8(((U_START/10) & 0x00FF) & 0xFF) // lb

      teensy.write_byteArray[I_byte_h] = UInt8(((I_START*10) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[I_byte_l] = UInt8(((I_START*10) & 0x00FF) & 0xFF) // lb
      
      

      
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
   
   @IBAction func report_I_Slider(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_I // Code 
      print("report_I_Slider IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let i = pos / Float(sender.maxValue) * 5.12
      let Istring = formatter.string(from: NSNumber(value: i))
      print("report_I_Slider pos: \(pos)  i: \(i) Istring: \(Istring ?? "0")")
      setI_Feld.stringValue  = Istring!
      let intpos = sender.intValue 
      self.setI_Stepper.floatValue = sender.floatValue

      teensy.write_byteArray[I_byte_h] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[I_byte_l] = UInt8((intpos & 0x00FF) & 0xFF) // lb

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_I_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_U // Code 
      print("report_I_Stepper IntVal: \(sender.intValue)")
      let I = setI_Feld.floatValue
      
      let pos = sender.floatValue
      let u = pos / Float(sender.maxValue) * 5.12      
      let Istring = formatter.string(from: NSNumber(value: u))
      print("report_U_Stepper u: \(u) Istring: \(Istring ?? "0")")
      setI_Feld.stringValue  = Istring!
      let intpos = sender.intValue 
      self.setI_Slider.floatValue = sender.floatValue
      
      teensy.write_byteArray[I_byte_h] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[I_byte_l] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   
   @IBAction func report_U_Slider(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_U // Code 
      print("report_U_Slider IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let intpos = sender.intValue 
      let u = (pos / Float(sender.maxValue)) * ADC_REF * U_DIVIDER  
      let Ustring = formatter.string(from: NSNumber(value: u))
      print("report_U_Slider pos: \(intpos)  u: \(u) Ustring: \(Ustring ?? "0")")
      setU_Feld.stringValue  = Ustring!
      
      self.setU_Stepper.floatValue = sender.floatValue
      //print("report_U_Slider")
      teensy.write_byteArray[U_byte_h] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[U_byte_l] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_U_Slider senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_U_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_U // Code 
      //print("report_U_Stepper IntVal: \(sender.intValue)")
      let U = setU_Feld.floatValue
      
      let intpos = sender.intValue 
      let pos = sender.floatValue
      //let u = (pos / Float(sender.maxValue)) * U_DIVIDER * ADC_REF   
      let u = pos
      let Ustring = formatter.string(from: NSNumber(value: u/100))
      print("report_U_Stepper  pos: \(intpos)   u: \(u) Ustring: \(Ustring ?? "0")")
      setU_Feld.stringValue  = Ustring!
      
      self.setU_Slider.floatValue = sender.floatValue
   
      teensy.write_byteArray[U_byte_h] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[U_byte_l] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_set_U(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_U // Code 
      
      // senden mit faktor 1000
      //let u = setU_Feld.floatValue 
      let U = setU_Feld.floatValue * 100
      let intU = UInt(U)
      
      let U_HI = (intU & 0xFF00) >> 8
      let U_LO = intU & 0x00FF
      
      //let U_LO = U * 1000 - 1000 * Float(U_HI)
      print("report_set_U U: \(U) U HI: \(U_HI) U LO: \(U_LO) ")
      let intpos = sender.intValue 
      self.setU_Slider.floatValue = U //sender.floatValue
      self.setU_Stepper.floatValue = U //sender.floatValue

      teensy.write_byteArray[U_byte_h] = UInt8(U_LO)
      teensy.write_byteArray[U_byte_l] = UInt8(U_HI)
      
       if (usbstatus > 0)
       {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_U U: %d",senderfolg)
         }
      }
   }
   
   @IBAction func report_P_Slider(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_P // Code 
      print("report_P_Slider IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let p = pos / Float(sender.maxValue) * 5.12
      let Pstring = formatter.string(from: NSNumber(value: p))
    //  print("report_U_Slider pos: \(intpos)  u: \(u) Ustring: \(Ustring ?? "0")")

      print("report_P_Slider p: \(p) Pstring: \(Pstring ?? "0")")
      setP_Feld.stringValue  = Pstring!
      let intpos = sender.intValue 
      teensy.write_byteArray[U_byte_h] = UInt8((intpos & 0x00FF) & 0xFF)
      teensy.write_byteArray[U_byte_l] = UInt8((intpos & 0xFF00) >> 8)
      _ = teensy.send_USB()
      
   }


   @IBAction func report_set_I(_ sender: AnyObject)
   {
      
   }

   
   
   
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         var start_read_USB_erfolg = teensy.start_read_USB(true)
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true

      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "report_start_read_USB: Kein USB-Device"
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
      let hidstatus = teensy.status()
      
      print("USBOpen usbstatus vor check: \(usbstatus) hidstatus: \(hidstatus)")
      if (usbstatus > 0) // already open
      {
         print("USB-Device ist schon da")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist schon da"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
        // return

      }
      let erfolg = teensy.USBOpen()
      usbstatus = erfolg
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
         print("status 1")
         USB_OK.backgroundColor = NSColor.green
         print("USB-Device da")
         /*
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist da"
         warnung.addButton(withTitle: "OK")
         //warnung.runModal()
          */
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
         warnung.messageText = "check_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         
         if let taste = USB_OK
         {
            //print("Taste USB_OK ist nicht nil")
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
         warnung.messageText = "send_USB: Kein USB-Device"
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

