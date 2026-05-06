import SwiftUI

struct LoadingView: View {
	var title: String?
	var dimOpacity: Double = 0.35

	init(_ title: String? = nil, dimOpacity: Double = 0.35) {
		self.title = title
		self.dimOpacity = dimOpacity
	}

	var body: some View {
		ZStack {
			Color.black.opacity(dimOpacity)
				.ignoresSafeArea()

			VStack(spacing: 12) {
				ProgressView()
					.tint(.primary)
				if let title, !title.isEmpty {
					Text(title)
						.font(.system(size: 14, weight: .medium))
						.foregroundStyle(.primary)
				}
			}
			.padding(20)
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
