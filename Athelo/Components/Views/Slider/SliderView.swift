//
//  SliderView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import Combine
import CombineCocoa
import UIKit

typealias SliderConfigurationData = SliderView.ConfigurationData

struct SliderStep {
    let font: UIFont
    let text: String
}

final class SliderView: PanInterceptingView {
    // MARK: - Outlets
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewSteps: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewStepsWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    private var isStepped: Bool = false
    private var stepsCount: Int = 0
    
    private var cancellables: [AnyCancellable] = []
    
    var sliderValue: Float {
        slider.value
    }
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
        
        configure()
        sink()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        
        configure()
        sink()
    }
    
    private func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }

        addSubview(view)
        view.frame = self.bounds
        
        superview?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        superview?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        superview?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        superview?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateStepsStackViewWidth()
    }
    
    // MARK: - Public API
    func setSliderValue(_ value: Float, animated: Bool = false) {
        guard slider.minimumValue...slider.maximumValue ~= value else {
            return
        }
        
        if isStepped, stepsCount >= 2 {
            slider.value = value
            updateSliderValue()
        } else {
            slider.setValue(value, animated: animated)
        }
    }
    
    // MARK: - Configuration
    private func configure() {
        configureSlider()
    }
    
    private func configureSlider() {
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(sliderRecognizedTapGesture(_:)))
        
        slider.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoSlider()
    }
    
    private func sinkIntoSlider() {
        slider.valuePublisher
            .removeDuplicates()
            .debounce(for: 0.05, scheduler: DispatchQueue.main)
            .dropFirst()
            .sinkDiscardingValue { [weak self] in
                self?.feedbackGenerator.selectionChanged()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func stepContainerView(for step: SliderStep) -> (stepView: UIStackView, descriptionLabel: UILabel) {
        let stepStackView = UIStackView()
        
        stepStackView.translatesAutoresizingMaskIntoConstraints = false
        stepStackView.axis = .vertical
        stepStackView.alignment = .center
        stepStackView.spacing = 4.0
        
        let stepDescriptionContainerView = UIView()
        
        stepDescriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
        stepDescriptionContainerView.backgroundColor = .clear
        
        let stepDescriptionLabel = UILabel()
        
        stepDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDescriptionLabel.font = step.font
        stepDescriptionLabel.textColor = .withStyle(.black)
        stepDescriptionLabel.text = step.text
        stepDescriptionLabel.textAlignment = .center
        stepDescriptionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        stepDescriptionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        stepDescriptionContainerView.addSubview(stepDescriptionLabel)
        
        NSLayoutConstraint.activate([
            stepDescriptionLabel.centerXAnchor.constraint(equalTo: stepDescriptionContainerView.centerXAnchor),
            stepDescriptionLabel.centerYAnchor.constraint(equalTo: stepDescriptionContainerView.centerYAnchor),
            stepDescriptionLabel.heightAnchor.constraint(equalTo: stepDescriptionContainerView.heightAnchor)
        ])
        
        let indicatorLineView = UIView()
        
        indicatorLineView.translatesAutoresizingMaskIntoConstraints = false
        indicatorLineView.backgroundColor = .withStyle(.gray)
        
        indicatorLineView.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
        indicatorLineView.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        stepStackView.addArrangedSubview(stepDescriptionContainerView)
        stepStackView.addArrangedSubview(indicatorLineView)
        
        stepStackView.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        return (stepStackView, stepDescriptionLabel)
    }
    
    private func steppedValue(for value: Float) -> Float? {
        guard isStepped, stepsCount >= 2 else {
            return nil
        }
        
        let step = (slider.maximumValue - slider.minimumValue) / Float(stepsCount - 1)
        
        var minValue = slider.minimumValue
        var maxValue = minValue + step
        
        let currentValue = value
        for _ in (0...stepsCount - 1) {
            if minValue...maxValue ~= currentValue {
                if currentValue > (minValue + (maxValue - minValue) / 2) {
                    return maxValue
                } else {
                    return minValue
                }
            }
            
            minValue += step
            maxValue += step
        }
        
        return nil
    }
    
    private func updateComponents(using configurationData: ConfigurationData) {
        slider.minimumValue = configurationData.minValue
        slider.maximumValue = configurationData.maxValue
        
        if let initialValue = configurationData.initialValue {
            let targetValue = max(configurationData.minValue, min(configurationData.maxValue, initialValue))
            slider.value = targetValue
        }
        
        let stepSubviews = stackViewSteps.subviews
        stepSubviews.forEach({
            $0.removeFromSuperview()
        })
        
        weak var weakSelf = self
        for step in configurationData.steps.enumerated() {
            let stepContainerView = stepContainerView(for: step.element)
            stackViewSteps.addArrangedSubview(stepContainerView.stepView)
            
            let stepButton = UIButton()
            stepButton.translatesAutoresizingMaskIntoConstraints = false
            stepButton.tag = step.offset + 1
            
            addSubview(stepButton)
            
            NSLayoutConstraint.activate([
                stepButton.topAnchor.constraint(equalTo: stepContainerView.descriptionLabel.topAnchor),
                stepButton.bottomAnchor.constraint(equalTo: stepContainerView.descriptionLabel.bottomAnchor),
                stepButton.leadingAnchor.constraint(equalTo: stepContainerView.descriptionLabel.leadingAnchor),
                stepButton.trailingAnchor.constraint(equalTo: stepContainerView.descriptionLabel.trailingAnchor)
            ])
            
            stepButton.addTarget(weakSelf, action: #selector(stepButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func updateSliderValue() {
        guard let steppedValue = steppedValue(for: slider.value) else {
            return
        }
        
        slider.value = steppedValue
    }
    
    private func updateStepsStackViewWidth() {
        let offset = (slider.thumbRect(forBounds: slider.bounds, trackRect: slider.trackRect(forBounds: slider.bounds), value: 0.0).width + 3.0) / 2.0
        
        if -offset != constraintStackViewStepsWidth.constant {
            constraintStackViewStepsWidth.constant = -offset
        }
    }
    
    // MARK: - Actions
    @IBAction private func sliderRecognizedTapGesture(_ sender: Any) {
        guard isStepped, stepsCount > 2,
              let gestureRecognizer = sender as? UITapGestureRecognizer else {
            return
        }
        
        let location = gestureRecognizer.location(in: slider)
        guard slider.bounds.contains(location) else {
            return
        }
        
        let value = Float(location.x / slider.bounds.maxX) * (slider.maximumValue - slider.minimumValue)
        guard let steppedValue = steppedValue(for: value), slider.value != steppedValue else {
            return
        }
        
        feedbackGenerator.prepare()
        
        slider.setValue(steppedValue, animated: true)
        
        feedbackGenerator.selectionChanged()
    }
    
    @IBAction private func sliderValueChanged(_ sender: Any) {
        updateSliderValue()
    }
    
    @IBAction private func stepButtonTapped(_ sender: Any) {
        guard let senderButton = (sender as? UIButton),
              senderButton.tag > 0 else {
            return
        }
        
        let step = (slider.maximumValue - slider.minimumValue) / Float(stepsCount - 1)
        let offset = step * Float(senderButton.tag - 1)
        
        guard let targetValue = steppedValue(for: slider.minimumValue + offset),
              targetValue != sliderValue else {
            return
        }
        
        feedbackGenerator.prepare()
        
        slider.setValue(targetValue, animated: true)
        
        feedbackGenerator.selectionChanged()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension SliderView: Configurable {
    struct ConfigurationData {
        let minValue: Float
        let maxValue: Float
        let initialValue: Float?
        let stepped: Bool
        let steps: [SliderStep]
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        isStepped = configurationData.stepped
        stepsCount = configurationData.steps.count
        
        updateComponents(using: configurationData)
    }
}
