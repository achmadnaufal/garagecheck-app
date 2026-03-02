import SwiftUI

/// Compact card showing fit result for a single car — used in CompareView.
struct FitResultCard: View {
    let result: FitResult

    var body: some View {
        VStack(spacing: 10) {
            Text(result.status.emoji)
                .font(.system(size: 40))

            Text(result.status.rawValue)
                .font(.headline)
                .foregroundColor(result.status.color)

            Text(result.car.fullDisplayName)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(result.car.segment)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)

            Divider()

            VStack(spacing: 6) {
                marginRow("Width", mm: result.widthMarginMm)
                marginRow("Length", mm: result.lengthMarginMm)
                marginRow("Height", mm: result.heightMarginMm)
            }
        }
        .padding(Constants.UI.padding)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private func marginRow(_ label: String, mm: Double) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(mm < 0
                 ? String(format: "-%.0fmm", abs(mm))
                 : String(format: "+%.0fmm", mm))
                .font(.caption.bold())
                .foregroundColor(colorForMargin(mm))
        }
    }

    private func colorForMargin(_ mm: Double) -> Color {
        if mm < 0 { return .red }
        if mm < Constants.Fit.tightThreshold { return .red }
        if mm < Constants.Fit.comfortableThreshold { return .orange }
        return .green
    }
}

struct FitResultCard_Previews: PreviewProvider {
    static var previews: some View {
        FitResultCard(result: FitResult(
            garage: .example,
            car: .example,
            status: .fits,
            lengthMarginMm: 405,
            widthMarginMm: 870,
            heightMarginMm: 705
        ))
        .padding()
    }
}
