#if !targetEnvironment(simulator)
import SwiftUI
import RoomPlan

// MARK: - Callback type
typealias RoomScanCompletion = (_ lengthMm: Double, _ widthMm: Double, _ heightMm: Double) -> Void

// MARK: - UIViewControllerRepresentable wrapper for RoomCaptureViewController
struct RoomCaptureRepresentable: UIViewControllerRepresentable {
    var onScanComplete: RoomScanCompletion
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> RoomCaptureHostViewController {
        let vc = RoomCaptureHostViewController()
        vc.onScanComplete = onScanComplete
        vc.onCancel = onCancel
        return vc
    }

    func updateUIViewController(_ uiViewController: RoomCaptureHostViewController, context: Context) {}
}

// MARK: - Host VC using RoomCaptureSession
@available(iOS 17.0, *)
class RoomCaptureHostViewController: UIViewController, RoomCaptureSessionDelegate, RoomCaptureViewDelegate {
    var onScanComplete: RoomScanCompletion?
    var onCancel: (() -> Void)?

    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSession: RoomCaptureSession!
    private var captureConfiguration: RoomCaptureSession.Configuration!
    private var finalRoom: CapturedRoom?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Setup RoomCaptureView
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        roomCaptureView.delegate = self
        view.addSubview(roomCaptureView)

        // Add Stop button
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("Done Scanning", for: .normal)
        stopButton.backgroundColor = UIColor.systemBlue
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 12
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopScan), for: .touchUpInside)
        view.addSubview(stopButton)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelScan), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            stopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 200),
            stopButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])

        // Setup session
        roomCaptureSession = roomCaptureView.captureSession
        roomCaptureSession.delegate = self
        captureConfiguration = RoomCaptureSession.Configuration()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        roomCaptureSession.run(configuration: captureConfiguration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomCaptureSession.stop()
    }

    @objc private func stopScan() {
        roomCaptureSession.stop()
    }

    @objc private func cancelScan() {
        roomCaptureSession.stop()
        onCancel?()
    }

    // MARK: - RoomCaptureViewDelegate
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        if let error = error {
            print("RoomPlan error: \(error)")
            onCancel?()
            return
        }
        extractDimensions(from: processedResult)
    }

    // MARK: - Dimension Extraction
    private func extractDimensions(from room: CapturedRoom) {
        // Extract the bounding box of all walls to find room dimensions
        var maxLength: Float = 0
        var maxWidth: Float = 0
        var maxHeight: Float = 0

        for wall in room.walls {
            // wall.dimensions: (width, height) for each wall surface
            let wallWidth = wall.dimensions.x
            let wallHeight = wall.dimensions.y

            if wallWidth > maxLength {
                maxLength = wallWidth
            }
            if wallHeight > maxHeight {
                maxHeight = wallHeight
            }
        }

        // For width: use the perpendicular wall
        // Sort walls by dimension to find length vs width pair
        let wallWidths = room.walls.map { $0.dimensions.x }.sorted(by: >)
        if wallWidths.count >= 2 {
            maxLength = wallWidths[0]
            maxWidth = wallWidths[1]
        } else if wallWidths.count == 1 {
            maxLength = wallWidths[0]
            maxWidth = wallWidths[0]
        }

        // Height from walls
        let heights = room.walls.map { $0.dimensions.y }
        maxHeight = heights.max() ?? 2.4

        // Convert meters → mm
        let lengthMm = Double(maxLength) * 1000
        let widthMm = Double(maxWidth) * 1000
        let heightMm = Double(maxHeight) * 1000

        DispatchQueue.main.async { [weak self] in
            self?.onScanComplete?(lengthMm, widthMm, heightMm)
        }
    }
}
#endif
