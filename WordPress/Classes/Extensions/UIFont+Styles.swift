extension UIFont {
    /// Returns a UIFont instance with the italic trait applied.
    func italic() -> UIFont {
        return withSymbolicTraits(.traitItalic)
    }

    /// Returns a UIFont instance with the semibold trait applied.
    func semibold() -> UIFont {
        return withWeight(.semibold)
    }

    func withSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: 0)
    }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])

        return UIFont(descriptor: descriptor, size: 0)
    }
}
