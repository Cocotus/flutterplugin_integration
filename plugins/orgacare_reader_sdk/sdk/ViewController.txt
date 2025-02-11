//
//  ViewController.swift
//  HealthDeviceTaskManager_iOS
//
//  Copyright (C) Worldline Healthcare GmbH
//
//  Main view controller for this demo.
//
//  • Created by Worldline Healthcare GmbH; tpe on 06.12.2021.
//

import UIKit
import WHCCareKit_iOS

class ViewController: UIViewController {

  /// Care bluetooth manager instance
  private let bluetoothManager = CareBluetoothManager()
  
  /// Care task manager instance
  private var taskManager: HealthDeviceTaskManager?
  
  /// PickerView for listing all detected devices
  @IBOutlet weak var devicePickerView: UIPickerView!
  
  @IBAction func connectButtonAction(_ sender: UIButton) {
    
    // MARK:  Connect to the Care
    
    // Simply connect to the selected device index in the picker view
    bluetoothManager.connectToDevice(deviceIndex: devicePickerView.selectedRow(inComponent: 0))
    
  }
  
  @IBAction func loadVSDButtonAction(_ sender: UIButton) {
    
    // MARK:  Load VSD data from the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForLoadVSD()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }

  @IBAction func cardToCardButtonAction(_ sender: UIButton) {
  
    // MARK:  Perform card to card on the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForPerformCardToCard()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }
  
  @IBAction func pinHandlingButtonAction(_ sender: UIButton) {
    
    // MARK:  Perform card to card on the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForHandleCardPin()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }

  @IBAction func accessFlagsButtonAction(_ sender: UIButton) {
    
    // MARK:  Perform checking access flags for the HBA / SMCB
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForGetAccessFlags()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }
  
  @IBAction func loadNFDButtonAction(_ sender: UIButton) {
    
    // MARK:  Load NFD data from the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForLoadNFD()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }
  
  @IBAction func LoadDPEButtonAction(_ sender: UIButton) {
    
    // MARK:  Load DPE data from the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForLoadDPE()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }
  
  @IBAction func loadAMTSButtonAction(_ sender: UIButton) {
    
    // MARK:  Load AMTS data from the Care
    
    // If the health device manager is initialized the task pool can be defined.
    createPoolForLoadAMTS()
    
    // Run the predefined task pool.
    runTaskPool()
    
  }
  
  @IBAction func disconnectButtonAction(_ sender: UIButton) {
    
    // MARK:  Cleanup and disconnect from the Care
    
    // Simply run the stop method of the task manager.
    taskManager?.stop(completion: {
      
      // If the stop method is finished the disconnect method of the
      // bluetooth  manager can be called.
      self.bluetoothManager.disconnectFromDevice()
      
    })
    
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // MARK:  Declare the current view controller as delegate for the bluetooth manager.
    //        This allows the current view controller to receive information from the
    //        bluetooth manager by implementing the protocol methodes.
    bluetoothManager.delegate = self
    
    // Setup the current view controller as delegate and data source for the device picker view
    devicePickerView.delegate = self
    devicePickerView.dataSource = self
    
  }

}

// MARK: - Implementation of the CareBluetoothManagerDelegate methodes

extension ViewController: CareBluetoothManagerDelegate {
  
  func careBluetoothManager(didUpdateState state: CareBluetoothManagerStates) {
    
    // MARK:  Receives the state of the bluetooth manager
    //
    //        When the state of the connection changes this method will be called.
    //
    //        For example:  The state can be used to check if the bluetooth manager is
    //                      currently connected or scanning.
    //
    //        All states are listed in the Xcode documentation for CareBluetoothManagerStates.
    
    // In this example the state is simply printed out to the terminal.
    
    print("careBluetoothManager didUpdateState> \(state)")
    
  }
  
  func careBluetoothManager(didThrowMessage message: CareBluetoothManagerMessages) {
    
    // MARK:  Receives a message from the bluetooth manager
    //
    //        With this method the bluetooth manager can inform about message events.
    //
    //        For example:  The messages can be used to check for example if a connection error
    //                      has occured or a new peripheral has been detected.
    //
    //        All states are listed in the Xcode documentation for CareBluetoothManagerMessages.
    
    // In this example the message is used to check for new detected peripherals.
    // If a peripheral has been detected the picker view will be triggered for
    // updating its components.
    
    print("careBluetoothManager didThrowMessage> \(message)")
    
    switch message {

    case .newPeripheralDetected: devicePickerView.reloadAllComponents()

    default: break
      
    }
    
  }
  
  func careBluetoothManager(didConnect ctapi: CTorgios) {
    
    // MARK:  Receives the CTAPI communication instance
    //
    //        With this method the bluetooth manager shares a CTAPI instance when the communication
    //        has been successful established.
    //
    //        The CTAPI instance can be used to initialize the Care task manager

    // In this example the task manager will be directly initialized with the receive CTAPI.
    
    taskManager = HealthDeviceTaskManager(ctapi: ctapi)
    
  }
  
}

// MARK: - Implementations for task handling

extension ViewController {
  
  /// Defines a task pool for receiving access flags for the HBA/SMCB
  private func createPoolForGetAccessFlags() {

    // Check if the task manager is available
    guard let manager = taskManager else {
      print("taskPool_AccessFlags> Task manager not available")
      return
    }

    // 1. Assign the task pool as closure
    manager.tasks.pool = {

      // Note:  Every task is available as a synchron and asynchron version.
      //        This example uses both versions for demonstration.
      //        Take a look at the Xcode in source documentation for a description.

      // 2. Call the task to ask the Care for inserting a card

      print("taskPool_AccessFlags> run insertCard")
      let insertCardResponse = manager.tasks.mobKT?.insertCard(waitingTime: 60, slotID: HealthDeviceConstants.MobKT.SlotIDs.Slot2)

      if insertCardResponse?.success == false {

        print("taskPool_AccessFlags> insertCard fails")

        // Example: This is how to access the trailer of the response.
        //          This can be used to evaluate errors.
        if let responseTrailer = insertCardResponse?.trailer?.value {
          print("taskPool_AccessFlags> insertCard trailer \(responseTrailer)")
        }

        return
      }

      // 3. Call the task that return access flags

      print("taskPool_AccessFlags> run getPinAccess")

      let getPinAccessResult = manager.tasks.ghc.getPinAccess()

      guard let accessDict = getPinAccessResult else {

        print("taskPool_AccessFlags> getPinAccess fails")
        return
      }

      print("taskPool_AccessFlags> getPinAccess receives data: \(accessDict)")

    }

  }
  
  /// Defines a task pool for loading the datasets of VSD of the eGK
  private func createPoolForLoadVSD() {

    // Check if the task manager is available
    guard let manager = taskManager else {
      print("taskPoolVSD> Task manager not available")
      return
    }

    // 1. Assign the task pool as closure
    manager.tasks.pool = {

      // Note:  Every task is available as a synchron and asynchron version.
      //        This example uses both versions for demonstration.
      //        Take a look at the Xcode in source documentation for a description.

      // 2. Call the task to ask the Care for inserting a card

      print("taskPoolVSD> run insertCard")
      let insertCardResponse = manager.tasks.mobKT?.insertCard(waitingTime: 60)

      if insertCardResponse?.success == false {

        print("taskPoolVSD> insertCard fails")

        // Example: This is how to access the trailer of the response.
        //          This can be used to evaluate errors.
        if let responseTrailer = insertCardResponse?.trailer?.value {
          print("taskPoolVSD> insertCard trailer \(responseTrailer)")
        }

        return
      }

      // 3. Call the task that reads the VSD dataset

      print("taskPoolVSD> run read_VSD")

      let readVSDResult = manager.tasks.eGK.read_VSD()
     
      if let error = readVSDResult.error {
        print("taskPoolVSD> read_VSD fails with error \(error)")
      }
      
      guard let dataStatusVD = readVSDResult.dataStatusVD,
            let dataPD = readVSDResult.dataPD,
            let dataVD = readVSDResult.dataVD,
            let dataGVD = readVSDResult.dataGVD
      else {

        print("taskPoolVSD> missing data")
        return
      }

      print("taskPoolVSD> read_VSD receives data: \(dataStatusVD) \(dataPD) \(dataVD) \(dataGVD)")

      // 4. Call the task for remove the card

      manager.tasks.mobKT?.ejectCard(waitingTime: 60, completion: { ejectCardResponse in

        if ejectCardResponse.success == true {
          print("taskPoolVSD> process finished successsful")
        } else {
          print("taskPoolVSD> ejectCard fails")
        }

      })

    }

  }
  
  /// Defines a task pool for performing card to card for an eGK and HBA/SMCB
  private func createPoolForPerformCardToCard() {
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("createPoolForPerformCardToCard> Task manager not available")
      return
    }
    
    // 1. Assign the task pool as closure
    manager.tasks.pool = {
      
      // 2. Call the task for perfoming card to card
      
      //    Info: The GHCTasks (ghc) to call authenticateCardToCard is a nicer notation,
      //          because the function automatically detects, if the second card is a HBA or SMCB.
      //          (It is possible to call authenticateCardToCard for eGK, HBA, SMCB and GHC,
      //          but its always the same behavior.)
      
      print("createPoolForPerformCardToCard> run authenticateCardToCard")
      
      let cardToCardResponse = manager.tasks.ghc.authenticateCardToCard(targetEnv: .test)
      
      if cardToCardResponse.success == true {
        
        print("createPoolForPerformCardToCard> Successfull authenticated")
        
      } else {
        
        print("createPoolForPerformCardToCard> Authentication was not successful")
        
        // If a trailer from the communication response is present
        // it could be used to get some more information of what wwent wrong
        
        if let trailer = cardToCardResponse.response?.trailer {
          let sw1String = String(format: "0x%02X", trailer.value.sw1)
          let sw2String = String(format: "0x%02X", trailer.value.sw2)
          print("createPoolForPerformCardToCard> Communication response: \(sw1String) \(sw2String)")
          
          if trailer.description.isEmpty {
            print("createPoolForPerformCardToCard> No response description available")
          } else {
            print("createPoolForPerformCardToCard> Response description: \(trailer.description)")
          }
        }
        
        // It is possible to get infrmations about an error and react to this
        
        if let error = cardToCardResponse.error {
          print("createPoolForPerformCardToCard> Returned error: \(error)")
        }
        
      }
      
    }
    
  }
  
  /// Defines a task pool for handling the card PIN
  private func createPoolForHandleCardPin() {
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("createPoolForHandleCardPin> Task manager not available")
      return
    }
    
    // 1. Assign the task pool as closure
    manager.tasks.pool = {
      
      // 2. Call the task to ask the Care for inserting a card
    
      print("createPoolForHandleCardPin> run insertCard")
      let insertCardResponse = manager.tasks.mobKT?.insertCard(waitingTime: 60, slotID: HealthDeviceConstants.MobKT.SlotIDs.Slot2)
      
      if insertCardResponse?.success == false {
        
        print("createPoolForHandleCardPin> insertCard fails")
        
        // Example: This is how to access the trailer of the response.
        //          This can be used to evaluate errors.
        if let responseTrailer = insertCardResponse?.trailer?.value {
          print("createPoolForHandleCardPin> insertCard trailer \(responseTrailer)")
        }
        
        return
      }
      
      // 3. Call the task for perfoming pin handling
      
      print("createPoolForHandleCardPin> run createPoolForVerifyCardPin")
      
      let verifyPinResponse = manager.tasks.mobKT?.verifyPin()
      
      if verifyPinResponse?.success == true {
        
        print("createPoolForHandleCardPin> Successfull PIN handling")
        
      } else {
        
        print("createPoolForHandleCardPin> PIN handling was not successful")
        
        // If a trailer from the communication response is present
        // it could be used to get some more information of what wwent wrong
        
        if let trailer = verifyPinResponse?.response?.trailer {
          print("createPoolForHandleCardPin> Communication response: \(trailer.description)")
        }
        
      }
      
    }
    
  }
    
  /// Defines a task pool for loading NFD of the eGK
  private func createPoolForLoadNFD() {
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("taskPoolNFD> Task manager not available")
      return
    }
    
    // 1. Assign the task pool as closure
    manager.tasks.pool = {
      
      // Note:  Every task is available as a synchron and asynchron version.
      //        Take a look at the Xcode in source documentation for a description.
      
      // 2. Call the task that reads the NFD datasets
      
      print("taskPoolNFD> run readNFD")
      
      let readNFDResult = manager.tasks.eGK.read_NFD(emergencyIndicator: true, updateIndicator: false)
      
      if let error = readNFDResult.error {
        print("taskPoolNFD> readNFD fails with error \(error)")
      }
      
      guard let dataStatusNFD = readNFDResult.dataStatusNFD,
            let dataNFD = readNFDResult.dataNFD else {
        
        print("taskPoolNFD> missing data")
        return
      }
      
      print("taskPoolNFD> readNFD receives data: \(dataStatusNFD)")
      print("taskPoolNFD> readNFD receives data: \(dataNFD)")
  
    }
    
  }
  
  /// Defines a task pool for loading DPE of the eGK
  private func createPoolForLoadDPE() {
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("taskPoolDPE> Task manager not available")
      return
    }
    
    // 1. Assign the task pool as closure
    manager.tasks.pool = {
      
      // Note:  Every task is available as a synchron and asynchron version.
      //        Take a look at the Xcode in source documentation for a description.
      
      // 2. Call the task that reads the DPE datasets
      
      print("taskPoolDPE> run readDPE")
      
      let readDPEResult = manager.tasks.eGK.read_DPE(emergencyIndicator: true, updateIndicator: false)
      
      if let error = readDPEResult.error {
        print("taskPoolDPE> readDPE fails with error \(error)")
      }
      
      guard let dataStatusDPE = readDPEResult.dataStatusDPE,
            let dataDPE = readDPEResult.dataDPE else {
        
        print("taskPoolDPE> missing data")
        return
      }
      
      print("taskPoolDPE> readDPE receives data: \(dataStatusDPE)")
      print("taskPoolDPE> readDPE receives data: \(dataDPE)")
      
    }
    
  }
  
  /// Defines a task pool for loading AMTS of the eGK
  private func createPoolForLoadAMTS() {
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("taskPoolAMTS> Task manager not available")
      return
    }
    
    // 1. Assign the task pool as closure
    manager.tasks.pool = {
      
      // Note:  Every task is available as a synchron and asynchron version.
      //        Take a look at the Xcode in source documentation for a description.
      
      // 2. Call the task that reads AMTS datasets
      
      print("taskPoolAMTS> run readAMTS")
      
      let readAMTSResult = manager.tasks.eGK.read_AMTS()
      
      if let error = readAMTSResult.error {
        print("taskPoolAMTS> raedAMTS fails with error \(error)")
      }
      
      guard let dataStatusAMTS = readAMTSResult.dataStatusAMTS,
            let dataEW = readAMTSResult.dataEW,
            let dataAMTS = readAMTSResult.dataAMTS else {
        
        print("taskPoolAMTS> missing data")
        return
      }
      
      print("taskPoolAMTS> readAMTS receives data: \(dataStatusAMTS)")
      print("taskPoolAMTS> readAMTS receives data for Einwilligung: \(dataEW) and for AMTS: \(dataAMTS)")
    
    }
    
  }
  
  /// Run the defined task pool
  private func runTaskPool() {
    
    // MARK: Perform the tasks that are defined in the pool
    
    // Check if the task manager is available
    guard let manager = taskManager else {
      print("runTaskPool> Task manager is not available")
      return
    }
    
    // Running tasks is done by simply running the predefined task pool.
    manager.run(errorHandler: { error in
      
      // Possible errors can be handled here.
      // Error are described in the HealthDeviceTaskManagerError enumeration.
      print("taskManager errorHandler> \(error)")
      
    })
    
  }
  
}

// MARK: - Implementation of the UIPickerViewDelegate methodes

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
 
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
    // To prepare the number of rows in the picker view the count of the discoveredPeripheralNames property
    // of the bluetooth manager can be used.
    
    return bluetoothManager.discoveredPeripheralNames.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    // To show all discovered devices in the picker view the discoveredPeripheralNames property
    // of the bluetooth manager can be used.
    
    return bluetoothManager.discoveredPeripheralNames[row]
  }
  
}
