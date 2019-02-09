//
//  QRCodeViewController.swift
//  X-Squad
//
//  Created by Avario on 24/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class QRCodeViewController: UITableViewController {
	
	let squad: Squad
	
	init(squad: Squad) {
		self.squad = squad
		super.init(nibName: nil, bundle: nil)
		
		title = "XWS QR Code"
		navigationItem.largeTitleDisplayMode = .never
		
		let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
		navigationItem.rightBarButtonItem = closeButton
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "XBackground")
		navigationController?.navigationBar.barStyle = .black
		
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = SquadCell.rowHeight
		tableView.contentInset.top = 20
		
		tableView.register(SquadCell.self, forCellReuseIdentifier: SquadCell.reuseIdentifier)
		
		let xws = XWS(squad: squad)
		let xwsData = try! JSONEncoder().encode(xws)
		
		let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
		
		let scale = UIScreen.main.scale
		
		qrFilter.setValue(xwsData, forKey: "inputMessage")
		let transform = CGAffineTransform(scaleX: 5 * scale, y: 5 * scale)
		
		let qrOutput = qrFilter.outputImage?.transformed(by: transform)
		
		let colorFilter = CIFilter(name: "CIFalseColor")!
		
		colorFilter.setValue(qrOutput, forKey: "inputImage")
		colorFilter.setValue(CIColor.white, forKey: "inputColor0")
		colorFilter.setValue(CIColor.clear, forKey: "inputColor1")
		
		let colorOutput = colorFilter.outputImage!
		
		let context = CIContext(options: nil)
		let cgImage = context.createCGImage(colorOutput, from: colorOutput.extent)
		
		let image = UIImage(cgImage: cgImage!, scale: scale, orientation: .up)
		
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 500))
		tableView.tableFooterView = footerView
		
		footerView.addSubview(imageView)
		imageView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 0).isActive = true
		imageView.widthAnchor.constraint(equalTo: footerView.widthAnchor).isActive = true
		imageView.heightAnchor.constraint(equalTo: footerView.heightAnchor, constant: -60).isActive = true
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let squadCell = tableView.dequeueReusableCell(withIdentifier: SquadCell.reuseIdentifier) as! SquadCell
		squadCell.squad = squad
		squadCell.selectionStyle = .none
		
		return squadCell
	}
	
}
