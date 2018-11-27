//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

import Cocoa


class ViewController: NSViewController
{
   
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var teensy = usb_teensy()
   
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start: NSButton!
   
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   @IBOutlet weak var USB_OK: NSOutlineView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!

   
   @IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
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
      teensy.write_byteArray[4] = UInt8((intpos & 0x00FF) & 0xFF)
      teensy.write_byteArray[5] = UInt8((intpos & 0xFF00) >> 8)
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
      teensy.start_read_USB(true)
      
      
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
         let manu = get_manu()
         //println(manu) // ok, Zahl
//         var manustring = UnsafePointer<CUnsignedChar>(manu)
         //println(manustring) // ok, Zahl
         
         let manufactorername = String(cString: UnsafePointer(manu!))
         print("str: %s", manufactorername)
         manufactorer.stringValue = manufactorername
         
         //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
      }
      else
         
      {
         print("status 0")
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
      }
      print("antwort: \(teensy.status())")
   }
   
   @IBAction func stop_read_USB(_ sender: AnyObject)
   {
      teensy.read_OK = false
   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      
      var senderfolg = teensy.send_USB()
      
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

