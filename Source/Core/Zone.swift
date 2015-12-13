//    Zone.swift
//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Nofel Mahmood ( https://twitter.com/NofelMahmood )
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import CloudKit

struct Zone {
  static let errorDomain = "com.seam.error.zone.errorDomain"
  enum Error: ErrorType {
    case ZoneCreationFailed
    case ZoneSubscriptionCreationFailed
  }
  static let name = "Seam_CustomZone"
  static let subscriptionName = "Seam_CustomZone_Subscription"
  static let nameKey = "com.seam.zone"
  static let subscriptionNameKey = "com.seam.zone.subscription"
  static var zone: CKRecordZone {
    return CKRecordZone(zoneID: zoneID)
  }
  static var zoneID: CKRecordZoneID {
    return CKRecordZoneID(zoneName: name, ownerName: CKOwnerDefaultName)
  }
  private static var zoneExists: Bool {
    return NSUserDefaults.standardUserDefaults().objectForKey(nameKey) != nil ? true: false
  }
  private static var zoneSubscriptionExists: Bool {
    return NSUserDefaults.standardUserDefaults().objectForKey(subscriptionNameKey) != nil ? true : false
  }
  static func createZone(operationQueue: NSOperationQueue) throws {
    var error: NSError?
    let modifyRecordZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
    modifyRecordZonesOperation.modifyRecordZonesCompletionBlock = { (_,_,operationError) in
      error = operationError
    }
    operationQueue.addOperation(modifyRecordZonesOperation)
    operationQueue.waitUntilAllOperationsAreFinished()
    guard error == nil else {
      throw Error.ZoneCreationFailed
    }
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: nameKey)
  }
  
  static func createSubscription(operationQueue: NSOperationQueue) throws {
    var error: NSError?
    let subscription = CKSubscription(zoneID: zoneID, subscriptionID: name, options: CKSubscriptionOptions(rawValue: 0))
    let subscriptionNotificationInfo = CKNotificationInfo()
    subscriptionNotificationInfo.alertBody = ""
    subscriptionNotificationInfo.shouldSendContentAvailable = true
    subscription.notificationInfo = subscriptionNotificationInfo
    subscriptionNotificationInfo.shouldBadge = false
    let modifyZoneSubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
    modifyZoneSubscriptionsOperation.modifySubscriptionsCompletionBlock = { (_,_,operationError) in
      error = operationError
    }
    operationQueue.addOperation(modifyZoneSubscriptionsOperation)
    operationQueue.waitUntilAllOperationsAreFinished()
    guard error == nil else {
      throw Error.ZoneSubscriptionCreationFailed
    }
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: subscriptionNameKey)
  }
}