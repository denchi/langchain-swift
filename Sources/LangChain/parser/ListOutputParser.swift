//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/4.
//

import Foundation
public struct ListOutputParser: BaseOutputParser, FormatInstructions {
    public init() {}
    public func parse(text: String) -> Parsed {
        Parsed.list(text.components(separatedBy: ","))
    }
    
    public func get_format_instructions() -> String {
        return "Your response should be a list of comma separated values, eg: `foo, bar, baz`"
    }
}
