//
//  PornHistory.swift
//  porrrrrrn
//
//  Created by Masaki Horimoto on 2016/12/06.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

class pornHistory : Object {
    dynamic var number = 0
    dynamic var pressDateTime = Date()
    dynamic var count = 0
}

class historyName : Object {
    dynamic var number = 0
    let pornHistories = List<pornHistory>()
    dynamic var historyName = ""
}

