//
//  SimpleNotification.swift
//  SimplifiedNotificationCenter
//
//  Created by Andrew Ashurow on 3/7/16.
//  Copyright © 2016 Andrew Ashurow. All rights reserved.
//

import Foundation
/// wrapper around NSNotificationCenter
public class SimpleNotification<T> :BaseNotificationProtocol{
    public typealias SimpleNotificationHandler = (value:T, sender:AnyObject?) -> Void
    
    private var
    notificationHandler:SimpleNotificationHandler?, // handler that store code block
    sender: AnyObject?,                             // notification sender(not required)
    name: String                                    // name for NSNotificationCenter
    /**
     Creates notification class.
     - parameter name:  name for NSNotificationCenter
     - parameter sender:  notification sender(not required)
     */
    public init(name: String, sender: AnyObject? = nil){
        self.name = name
        self.sender = sender
    }
    //MARK: public methods
    /**
     subscribe to notification with handler or unSubscribe from notifications.
     - parameter handler:  handler(value, sender). If handler == nil, unSubscribe() will be performed
     */
    public func subscribe(_ handler: SimpleNotificationHandler?){
        unSubscribe()
        if handler != nil {
            notificationHandler = handler
            _subscribe()
        }
    }
    /**
     Posts the notification with the given value to the specified center.
     - parameter object:  The data to be sent with the notification.
     */
    public func post(_ object: T) {
        let data = Wrapper<T>(theValue: object)
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: data)
    }
    /**
     Unsubscribe and remove notificationHandler
     */
    public func unSubscribe(){
        notificationHandler = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: private methods
    private func _subscribe(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.methodOfReceivedNotification(_:)),
            name:NSNotification.Name(rawValue: name),
            object: nil
        )
    }
    
    @objc func methodOfReceivedNotification(_ notification: Notification){
        if let value = (notification.object as? Wrapper<T>)?.wrappedValue{
            notificationHandler?(value: value, sender: sender)
        } else {
            var givenTypeString = "nil"
            if let givenType = notification.object?.dynamicType{
                givenTypeString = String(givenType)
            }
            handleError("SimpleNotification TYPE ERROR \n expected type: \(T.self) \n given type:     \(givenTypeString)")
        }
    }
    
    deinit {
        unSubscribe()
    }
    
}

//for tests
/// public for wrapper around NSNotificationCenter
public protocol BaseNotificationProtocol {
    associatedtype T
    /**
     subscribe to notification with handler or unSubscribe from notifications.
     - parameter handler:  handler(value, sender). If handler == nil, unSubscribe() will be performed
     */
    func subscribe(_ handler: ((value:T, sender:AnyObject?) -> Void)?)
    /**
     Posts the notification with the given value to the specified center.
     - parameter object:  The data to be sent with the notification.
     */
    func post(_ object: T)
    /**
     Unsubscribe and remove notificationHandler
     */
    func unSubscribe()
}

extension SimpleNotification {
    func handleError(_ text:String){
        #if DEBUG
            preconditionFailure(text)
        #else
            //dont crash app in production mode
            print(text)
        #endif
    }
}


class Wrapper<T>:AnyObject {
    var wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}
