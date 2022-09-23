//
//  RegisterSymptomsViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import SwiftDate
import UIKit

final class RegisterSymptomsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonAddSymptom: UIButton!
    @IBOutlet private weak var buttonEditInformation: UIButton!
    @IBOutlet private weak var collectionViewSymptoms: UICollectionView!
    @IBOutlet private weak var formTextFieldSymptom: FormTextField!
    @IBOutlet private weak var labelFeelingsHeader: UILabel!
    @IBOutlet private weak var labelSelectedDate: UILabel!
    @IBOutlet private weak var labelSelectedWeekday: UILabel!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var sliderFeelings: SliderView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewDate: UIStackView!
    @IBOutlet private weak var stackViewFeelings: UIStackView!
    @IBOutlet private weak var stackViewSymptoms: UIStackView!
    @IBOutlet private weak var viewCalendarContainer: UIView!
    @IBOutlet private weak var viewDateContainer: UIView!
    @IBOutlet private weak var viewFeelingsContainer: UIView!
    @IBOutlet private weak var viewScreenEdgeInterceptor: PanInterceptingView!
    @IBOutlet private weak var viewSymptomsContainer: UIView!
    
    private var calendarView: HorizontalWeekContainerView?
    private weak var symptomInputView: ListInputView?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintSymptomsCollectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = RegisterSymptomsViewModel()
    private var router: RegisterSymptomsRouter?
    
    private lazy var symptomsDataSource = createSymptomsCollectionViewDataSource()
    private lazy var symptomsLayout = createSymptomsCollectionViewLayout()
    
    private var symptomDismissalGestureRecognizer: UITapGestureRecognizer?
    
    private var cancellables: [AnyCancellable] = []
    private var interactiveGestureTriggerCancellable: AnyCancellable?
    private var symptomInputCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Configuration
    private func configure() {
        configureAddSymptomButton()
        configureCalendarContainerView()
        configureFeelingsSlider()
        configureFeelingsStackView()
        configureOwnView()
        configureScreenEdgeInterceptorView()
        configureSelectedDateLabel()
        configureSelectedWeekdayLabel()
        configureSymptomFormTextField()
        configureSymptomsCollectionView()
    }
    
    private func configureAddSymptomButton() {
        buttonAddSymptom.isHidden = true
        buttonAddSymptom.alpha = 0.0
    }
    
    private func configureCalendarContainerView() {
        guard calendarView == nil else {
            return
        }
        
        let calendarView = HorizontalWeekContainerView(model: viewModel.selectedDateModel, lastDisplayedDate: viewModel.referenceDate)
        
        embedView(calendarView, to: viewCalendarContainer)
        
        self.calendarView = calendarView
    }
    
    private func configureScreenEdgeInterceptorView() {
        if let navigationController = navigationController {
            viewScreenEdgeInterceptor.assignInterceptedNavigationController(navigationController)
        }
    }
    
    private func configureFeelingsSlider() {
        if let navigationController = navigationController {
            sliderFeelings.assignInterceptedNavigationController(navigationController)
        }
        
        sliderFeelings.assignConfigurationData(.init(minValue: 1, maxValue: 100, initialValue: 1, stepped: true, steps: [
            .init(font: .withStyle(.emoji), text: "😊"),
            .init(font: .withStyle(.emoji), text: "🤕"),
            .init(font: .withStyle(.emoji), text: "😓")
        ]))
    }
    
    private func configureFeelingsStackView() {
        stackViewFeelings.setCustomSpacing(40.0, after: sliderFeelings)
    }
    
    private func configureOwnView() {
        title = "navigation.symptom.wellbeing".localized()
    }
    
    private func configureSelectedDateLabel() {
        labelSelectedDate.text = viewModel.referenceDate.toFormat("MMMM dd, yyyy")
    }
    
    private func configureSelectedWeekdayLabel() {
        labelSelectedWeekday.text = viewModel.referenceDate.toFormat("EEEE")
    }
    
    private func configureSymptomFormTextField() {
        formTextFieldSymptom.isHidden = true
        formTextFieldSymptom.alpha = 0.0
        
        formTextFieldSymptom.delegate = self
    }
    
    private func configureSymptomsCollectionView() {
        collectionViewSymptoms.register(PillCollectionViewCell.self)
        
        collectionViewSymptoms.collectionViewLayout = symptomsLayout
        collectionViewSymptoms.dataSource = symptomsDataSource
        collectionViewSymptoms.delegate = self
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoSymptomFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoSymptomFormTextField() {
        formTextFieldSymptom.displayIcon(.verticalChevron)
            .sink { [weak self] in
                guard self?.viewModel.isEditing == true else {
                    return
                }
                
                if self?.symptomInputView == nil {
                    self?.displaySymptomInputView()
                } else {
                    self?.hideSymptomInputView()
                    self?.view.endEditing(true)
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.activeItemPublisher
            .compactMap({ $0?.date.toFormat("MMMM dd, yyyy") })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelSelectedDate)
            .store(in: &cancellables)
        
        viewModel.activeItemPublisher
            .compactMap({ $0?.date.toFormat("EEEE") })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelSelectedWeekday)
            .store(in: &cancellables)
        
        viewModel.activeItemPublisher
            .compactMap({ $0?.feeling?.feeling ?? .good })
            .map({ $0.displayableValue() })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.sliderFeelings.setSliderValue($0)
            }.store(in: &cancellables)
        
        viewModel.$feelingHeader
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelFeelingsHeader)
            .store(in: &cancellables)
        
        viewModel.isEditingPublisher
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateComponentsVisibilityBasedOnEditingState($0)
            }.store(in: &cancellables)
        
        viewModel.$selectedSymptom
            .map({ $0 != nil })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.buttonAddSymptom.isEnabled = $0
            }.store(in: &cancellables)
        
        viewModel.$selectedSymptom
            .map({ $0?.name })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.formTextFieldSymptom.text = $0
            }.store(in: &cancellables)
        
        viewModel.$symptomsSnapshot
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let shouldBeDisplayed = !$0.itemIdentifiers.isEmpty
                if self?.collectionViewSymptoms.isHidden != !shouldBeDisplayed {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                        self?.collectionViewSymptoms.isHidden = !shouldBeDisplayed
                        self?.collectionViewSymptoms.alpha = shouldBeDisplayed ? 1.0 : 0.0
                    }
                }
                
                self?.symptomsDataSource.apply($0, animatingDifferences: false, completion: {
                    let contentHeight = self?.symptomsLayout.collectionViewContentSize.height ?? 0.0
                    if self?.constraintSymptomsCollectionViewHeight.constant != contentHeight {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                            self?.constraintSymptomsCollectionViewHeight.constant = contentHeight
                            self?.view.layoutIfNeeded()
                        }
                    }
                })
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createSymptomsCollectionViewDataSource() -> UICollectionViewDiffableDataSource<RegisterSymptomsViewModel.SectionIdentifier, RegisterSymptomsViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<RegisterSymptomsViewModel.SectionIdentifier, RegisterSymptomsViewModel.ItemIdentifier>(collectionView: collectionViewSymptoms) { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withClass: PillCollectionViewCell.self, for: indexPath)
            
            cell.assignWidthBoundary(collectionView.bounds.size.width)
            if let decorationData = self?.viewModel.symptomDecorationData(at: indexPath) {
                cell.configure(decorationData, indexPath: indexPath)
            }
            
            if let self = self {
                cell.assignDelegate(self)
            }
            
            return cell
        }
        
        return dataSource
    }
    
    private func createSymptomsCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1.0), heightDimension: .estimated(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(16.0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16.0
            
            return section
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func displaySymptomDetailsPopup(with configurationData: SymptomDetailsPopupConfigurationData) {
        let view = SymptomDetailsPopupView.instantiate()
        
        view.assignConfigurationData(configurationData)
        view.assignDelegate(self)
        
        AppRouter.current.windowOverlayUtility.displayCustomOverlayView(view) { pinnedView, superview in
            pinnedView.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(pinnedView)
            
            NSLayoutConstraint.activate([
                pinnedView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                pinnedView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                pinnedView.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -32.0),
                pinnedView.topAnchor.constraint(greaterThanOrEqualTo: superview.safeAreaLayoutGuide.topAnchor, constant: 16.0),
                superview.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: pinnedView.safeAreaLayoutGuide.bottomAnchor, constant: 16.0)
            ])
            
            pinnedView.setNeedsLayout()
            pinnedView.layoutIfNeeded()
        }
    }
    
    private func displaySymptomInputView() {
        guard symptomInputView == nil else {
            return
        }
        
        let inputView = ListInputView.instantiate()
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.alpha = 0.0
        
        scrollViewContent.addSubview(inputView)
        symptomInputView = inputView
        
        adjustFrameOfFormInputView(inputView, inRelationTo: formTextFieldSymptom, inside: stackViewSymptoms, of: scrollViewContent, estimatedComponentHeight: inputView.maximumExpectedContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            inputView.alpha = 1.0
        }

        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleSymptomInputViewDismissalGestureRecognizer(_:)))
        tapGestureRecognizer.delegate = self
        
        if let oldGestureRecognizer = symptomDismissalGestureRecognizer {
            view.removeGestureRecognizer(oldGestureRecognizer)
        }
        
        view.addGestureRecognizer(tapGestureRecognizer)
        symptomDismissalGestureRecognizer = tapGestureRecognizer
        
        inputView.assignAndFireItemsPublisher(viewModel.symptomListPublisher(), preselecting: viewModel.selectedSymptom)
        
        symptomInputCancellable?.cancel()
        symptomInputCancellable = inputView.selectedItemPublisher
            .compactMap({ $0 as? SymptomData })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.viewModel.assignSelectedSymptom(value)
                
                self?.hideSymptomInputView()
                self?.view.endEditing(true)
            }
        
        view.endEditing(true)
        
        formTextFieldSymptom.activateIcon(.verticalChevron)
    }
    
    private func hideSymptomInputView() {
        guard symptomInputView != nil else {
            return
        }
        
        if let symptomDismissalGestureRecognizer = symptomDismissalGestureRecognizer {
            view.removeGestureRecognizer(symptomDismissalGestureRecognizer)
            self.symptomDismissalGestureRecognizer = nil
        }
        
        formTextFieldSymptom.deactivateIcon(.verticalChevron)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.symptomInputView?.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                self?.symptomInputView?.removeFromSuperview()
                self?.symptomInputView = nil
            }
        }
    }
    
    private func updateComponentsVisibilityBasedOnEditingState(_ isEditing: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            if self?.buttonAddSymptom.isHidden != !isEditing {
                self?.buttonAddSymptom.isHidden = isEditing ? false : true
                self?.buttonAddSymptom.alpha = isEditing ? 1.0 : 0.0
            }
            
            if self?.buttonEditInformation.isHidden != isEditing {
                self?.buttonEditInformation.isHidden = isEditing ? true : false
                self?.buttonEditInformation.alpha = isEditing ? 0.0 : 1.0
            }
            
            if self?.formTextFieldSymptom.isHidden != !isEditing {
                self?.formTextFieldSymptom.isHidden = isEditing ? false : true
                self?.formTextFieldSymptom.alpha = isEditing ? 1.0 : 0.0
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func addSymptomButtonTapped(_ sender: Any) {
        guard let selectedSymptom = viewModel.selectedSymptom else {
            return
        }
        
        displaySymptomDetailsPopup(with: .init(symptom: selectedSymptom, mode: .edit))
    }
    
    @IBAction private func editInformationButtonTapped(_ sender: Any) {
        viewModel.switchEditingState()
    }
    
    @IBAction private func handleSymptomInputViewDismissalGestureRecognizer(_ sender: Any) {
        guard (sender as? UITapGestureRecognizer) == symptomDismissalGestureRecognizer else {
            return
        }
        
        hideSymptomInputView()
    }
    
    @IBAction private func saveMyFeelingsButtonTapped(_ sender: Any) {
        viewModel.registerFeelingValue(sliderFeelings.sliderValue)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension RegisterSymptomsViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .symptom
    }
}

// MARK: Routable
extension RegisterSymptomsViewController: Routable {
    func assignRouter(_ router: RegisterSymptomsRouter) {
        self.router = router
    }
}

// MARK: PillCollectionViewCellDelegate
extension RegisterSymptomsViewController: PillCollectionViewCellDelegate {
    func pillCollectionViewCell(_ cell: PillCollectionViewCell, asksToRemoveItemWithIdentifier itemIdentifier: Int) {
        guard let symptom = viewModel.symptom(with: itemIdentifier) else {
            return
        }
        
        let deleteAction = PopupActionData(title: "action.delete".localized(), customStyle: .destructive) { [weak self] in
            self?.viewModel.removeSymptom(with: symptom.id)
        }
        let cancelAction = PopupActionData(title: "action.cancel".localized(), customStyle: .secondary)
        let popupConfigurationData = PopupConfigurationData(template: .deleteSymptom, primaryAction: deleteAction, secondaryAction: cancelAction)
        
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupConfigurationData)
    }
}

// MARK: SymptomDetailsPopupViewDelegate
extension RegisterSymptomsViewController: SymptomDetailsPopupViewDelegate {
    func symptomDetailsPopupViewAsksToClose(_ popupView: SymptomDetailsPopupView) {
        AppRouter.current.windowOverlayUtility.hideCustomOverlayView(of: SymptomDetailsPopupView.self)
    }
    
    func symptomDetailsPopupViewAsksToPerformAction(_ popupView: SymptomDetailsPopupView) {
        let note = popupView.note
        let wasEditing = popupView.isEditing
        
        AppRouter.current.windowOverlayUtility.hideCustomOverlayView(of: SymptomDetailsPopupView.self)
        
        if wasEditing {
            if let note = note, !note.isEmpty {
                viewModel.assignSymptomNote(note)
            }
            viewModel.addSelectedSymptom()
        } else {
            guard let symptomID = popupView.symptom?.id else {
                return
            }
            
            router?.navigateToSymptomDescription(using: .init(modelListData: .id([symptomID]), displaysChronologyButton: false))
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension RegisterSymptomsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {        
        if let symptomInputView = symptomInputView,
           symptomInputView.bounds.contains(touch.location(in: symptomInputView)) {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: UITextFieldDelegate
extension RegisterSymptomsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        !formTextFieldSymptom.containsInstanceOfTextField(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if formTextFieldSymptom.containsInstanceOfTextField(textField) {
            displaySymptomInputView()
            
            view.endEditing(true)
            return false
        }
        
        return true
    }
}

// MARK: - UICollectionViewDelegate
extension RegisterSymptomsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let symptomData = viewModel.symptomData(at: indexPath) else {
            return
        }
        
        displaySymptomDetailsPopup(with: .init(symptom: symptomData.symptom, mode: .read(description: symptomData.note)))
    }
}
