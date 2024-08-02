//
//  CellExtension.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import DSKit

extension WorkTimePicker: CellRepresentable {
    public static func createInstance() -> Self {
        WorkTimePicker(placeholderText: "") as! Self
    }
}

extension CalendarOpenButton: CellRepresentable {
    public static func createInstance() -> Self {
        CalendarOpenButton() as! Self
    }
}

extension TextFieldWithDegree: CellRepresentable {
    public static func createInstance() -> Self {
        let field = TextFieldWithDegree(degreeText: "", initialText: "")
        field.textField.keyboardType = .decimalPad
        return field as! Self
    }
}

extension StateButtonTyp1: CellRepresentable {
    public static func createInstance() -> Self {
        return StateButtonTyp1(text: "", initial: .normal) as! Self
    }
}

extension MultiLineTextField: CellRepresentable {
    public static func createInstance() -> Self {
        return MultiLineTextField(typography: .Body3, placeholderText: "") as! Self
    }
}
