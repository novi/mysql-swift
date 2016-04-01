//
//  ResultExtention.swift
//  MySQL
//
//  Created by Kyle Brown on 3/30/2016AD.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//
import CMySQL
import Foundation

extension QueryRowResult {
	
	public func allFields() -> [String:enum_field_types] {
		var returnFields: [String:enum_field_types] = [:]
		
		for field in fields {
			returnFields[field.name] = field.type
		}
		
		return returnFields
	}
	
}
