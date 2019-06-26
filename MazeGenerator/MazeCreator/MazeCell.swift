//
//  MazeCell.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 13/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

class MazeCell: UIView {
    
    enum Side {
        case TopSide, BottomSide, LeftSide, RightSide
    }
    
    lazy var icon = UIView()
    
    let coordinate: (Int, Int)
    let exitDirections: Set<Direction>
    
    init(rowNumber: Int, columnNumber: Int, exitDirections: Set<Direction>, frame: CGRect) {
        
        self.coordinate = (rowNumber, columnNumber)
        self.exitDirections = exitDirections
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        drawWallsFor(exitDirections: self.exitDirections)
    }
    
    func animateIcon() {
        icon = UIView(frame: .zero)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        icon.layer.cornerRadius = 10
        icon.backgroundColor = .gray
    }
    
    func removeIcon() {
        icon.removeFromSuperview()
    }
    
    func drawWallsFor(exitDirections: Set<Direction>) {
        
        switch exitDirections {
            //Single exits connect to border of maze
        case Set([.Left]):  drawBorder(on: [.TopSide, .BottomSide, .RightSide])
        case Set([.Right]): drawBorder(on: [.TopSide, .BottomSide, .LeftSide])
        case Set([.Up]):    drawBorder(on: [.LeftSide, .RightSide, . BottomSide])
        case Set([.Down]):  drawBorder(on: [.LeftSide, .RightSide, .TopSide])
            
        case Set([.Left, .Right]):  drawBorder(on: [.BottomSide, .TopSide])
        case Set([.Up, .Down]):     drawBorder(on: [.LeftSide, .RightSide])
        case Set([.Up, .Right]):    drawBorder(on: [.LeftSide, .BottomSide])
        case Set([.Up, .Left]):     drawBorder(on: [.RightSide, .BottomSide])
        case Set([.Down, .Right]):  drawBorder(on: [.TopSide, .LeftSide])
        case Set([.Down, .Left]):   drawBorder(on: [.TopSide, .RightSide])
        //Three exit cases
        case Set([.Up, .Down, .Right]):     drawBorder(on: [.LeftSide])
        case Set([.Up, .Down, .Left]):      drawBorder(on: [.RightSide])
        case Set([.Up, .Left, .Right]):     drawBorder(on: [.BottomSide])
        case Set([.Down, .Left, .Right]):   drawBorder(on: [.TopSide])
            
        default:
            print("Case fallthrough for \(exitDirections)")
        }
        
    }
    
    func drawBorder(on sides: [Side]) {
        if sides.contains(.TopSide) {
            
            let border: UIView = {
                let view = UIView()
                view.backgroundColor = .black
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            addSubview(border)
            
            border.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        if sides.contains(.LeftSide) {
            
            let border: UIView = {
                let view = UIView()
                view.backgroundColor = .black
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            addSubview(border)
            
            border.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            border.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        }
        if sides.contains(.BottomSide) {
            
            let border: UIView = {
                let view = UIView()
                view.backgroundColor = .black
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            addSubview(border)
            
            border.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        if sides.contains(.RightSide) {
            
            let border: UIView = {
                let view = UIView()
                view.backgroundColor = .black
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            addSubview(border)
            
            border.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            border.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
    }
    
    func setExit() {
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
