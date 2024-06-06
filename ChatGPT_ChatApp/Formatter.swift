//
//  Formatter.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/27/24.
//

import Foundation

let dateformat: DateFormatter = {
      let formatter = DateFormatter()
       formatter.dateFormat = "YYYY년 M월 d일"
       return formatter
}()
