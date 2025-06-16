import SwiftUI

public struct AuthTextField: View {
	let icon: Image
	let placeholder: String
	let isSecure: Bool
	let keyboardType: UIKeyboardType
	@Binding var text: String
	public init(
		icon: Image,
		placeholder: String,
		isSecure: Bool,
		keyboardType: UIKeyboardType,
		text: Binding<String>
	) {
		self.icon = icon
		self.placeholder = placeholder
		self.isSecure = isSecure
		self.keyboardType = keyboardType
		self._text = text
	}
	public var body: some View {

            HStack {
                icon
                    .fontWeight(.semibold)
                    .frame(width: 30)
                    .padding()
                VStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
                    Divider()
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
            }
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .enableInjection()
        }

        #if DEBUG
        @ObserveInjection var forceRedraw
        #endif
}
