//
//  ReportViewController.swift
//  PoodleSurf
//
//  Created by Westin Newell on 4/9/19.
//  Copyright © 2019 Haiku. All rights reserved.
//

import UIKit
import Diez

class ReportViewController: UIViewController {
    private let diezDesignSystem = Diez<DesignSystem>()
    private let diezModelMock = Diez<ReportModelMock>()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleView

        let state = ReportState.makeExample()
        let binder = ReportViewStateBinder(view: reportView)
        binder.update(with: state)

        applyFallbackStyleTo(reportView: reportView, titleView: titleView)

        diezDesignSystem.attach(self) { [weak self] system in
            self?.apply(system)
        }

        diezModelMock.attach(self) { mock in
            guard let state = ReportState(mock: mock) else {
                print("Failed to create state from Diez mock.")
                return
            }

            binder.update(with: state)
        }
    }

    private func apply(_ system: DesignSystem) {
        UIView.animate(withDuration: 0.5) {
            self.apply(system.report, to: self.reportView)
            self.view.layoutIfNeeded()
        }
    }

    private func apply(_ design: ReportDesign, to view: ReportView) {
        view.backgroundColor = design.backgroundColor.color
        view.contentLayoutMargins = UIEdgeInsets(design.contentLayoutMargins)
        view.contentSpacing = design.contentSpacing

        apply(design.header, to: view.headerView)
        apply(design.waterTemperature, to: view.temperatureCardView)
        apply(design.wind, to: view.windCardView)
        apply(design.swell, to: view.swellCardView)
        apply(design.tide, to: view.tideCardView)
    }

    private func apply(_ design: HeaderDesign, to view: ReportHeaderView) {
        design.regionLabel.setTextStyle(forLabel: view.regionLabel)
        design.placeLabel.setTextStyle(forLabel: view.placeLabel)
        view.pinIconImageView.image = try? design.mapPinIcon.image()
        view.locationImageView.strokeWidth = design.locationImage.strokeWidth
        view.locationImageView.strokeGradient = Gradient(design.locationImage.strokeGradient)
        view.locationImageWidthAndHeight = design.locationImage.widthAndHeight
        view.bannerHeight = design.bannerHeight
        view.labelsStackViewLayoutMargins = UIEdgeInsets(design.labelsLayoutMargin)
        view.regionLabelToPinIconSpacing = design.pinIconToLabelSpacing
        view.labelsVerticalSpacing = design.labelsSpacing
    }

    private func apply(_ design: WaterTemperatureCardDesign, to view: TemperatureCardView) {
        view.horizontalSpacing = design.horizontalSpacing
        view.titleLabel.text = design.title
        design.titleTextStyle.setTextStyle(forLabel: view.titleLabel)
        view.gradient = Gradient(design.gradient)
        apply(design.temperature, to: view.temperatureView)
        apply(design.wetsuit, to: view.wetsuitView)
    }

    private func apply(_ design: TemperatureDesign, to view: HorizontalImageLabelView) {
        design.textStyle.setTextStyle(forLabel: view.label)
        view.imageView.image = try? design.icon.image()
        view.spacing = design.iconSpacing
    }

    private func apply(_ design: WetsuitDesign, to view: HorizontalImageVerticalLabelsView) {
        view.topLabel.text = design.headerText
        design.headerTextStyle.setTextStyle(forLabel: view.topLabel)
        design.valueTextStyle.setTextStyle(forLabel: view.bottomLabel)
        view.verticalSpacing = design.labelSpacing
        view.horizontalSpacing = design.iconSpacing
    }

    private func apply(_ design: ForecastCardDesign, to view: ForecastCardView) {
        view.titleLabel.text = design.title
        design.titleTextStyle.setTextStyle(forLabel: view.titleLabel)
        view.gradient = Gradient(design.gradient)
        view.dayPartsHorizontalSpacing = design.dayPartSpacing
        view.separatorWidth = design.separatorWidth
        view.separators.forEach { $0.backgroundColor = design.separatorColor.color }
        view.dayParts.forEach { dayPart in
            dayPart.unitLabel.text = design.unit
            dayPart.valueUnitLayoutMargins = UIEdgeInsets(design.valueUnitMargins)
            apply(design.dayPart, to: dayPart)
        }
    }

    private func apply(_ design: SharedDayPartDesign, to view: DayPartView) {
        design.valueTextStyle.setTextStyle(forLabel: view.valueLabel)
        design.unitTextStyle.setTextStyle(forLabel: view.unitLabel)
        design.timeTextStyle.setTextStyle(forLabel: view.timeLabel)
        view.valueUnitSpacing = design.valueUnitSpacing
        view.layoutMargins = UIEdgeInsets(design.layoutMargins)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = ReportView(frame: UIScreen.main.bounds)
    }

    private var reportView: ReportView {
        return view as! ReportView
    }

    private let titleView = HorizontalImageLabelView()

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError("\(#function) not implemented.") }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("\(#function) not implemented.") }
}
