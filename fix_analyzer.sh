#!/bin/bash

# Script to fix Flutter analyzer issues
# This script helps resolve the 9K+ false positive errors

echo "🔧 Fixing Flutter Analyzer Issues..."
echo ""

# Step 1: Clean Flutter project
echo "Step 1: Cleaning Flutter project..."
flutter clean
echo "✅ Cleaned"

# Step 2: Get dependencies
echo ""
echo "Step 2: Getting dependencies..."
flutter pub get
echo "✅ Dependencies installed"

# Step 3: Repair pub cache
echo ""
echo "Step 3: Repairing pub cache..."
dart pub cache repair
echo "✅ Pub cache repaired"

# Step 4: Verify Flutter installation
echo ""
echo "Step 4: Verifying Flutter installation..."
flutter doctor -v
echo "✅ Flutter verified"

# Step 5: Run analyzer on a single file to test
echo ""
echo "Step 5: Testing analyzer..."
flutter analyze lib/main.dart 2>&1 | head -20

echo ""
echo "✅ Done! Please restart your IDE and reload the Dart Analysis Server."
echo ""
echo "📝 Next steps:"
echo "   1. Close VS Code completely"
echo "   2. Reopen VS Code"
echo "   3. Press Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows/Linux)"
echo "   4. Type 'Dart: Restart Analysis Server' and press Enter"
echo "   5. Wait for indexing to complete (check bottom right status bar)"

